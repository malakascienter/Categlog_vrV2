/*  Recompute metrics from scratch.

    @MemberIdsJson limits the rebuild to specific members, which is what the
    incremental path uses. Null rebuilds everyone.

    One set-based pass per source rather than a cursor: at 14,000 members a
    row-by-row rebuild would take minutes and lock the transaction table for the
    duration.                                                                    */
CREATE PROCEDURE dbo.LTYC_MemberMetrics_Rebuild
    @PropertyId    int,
    @MemberIdsJson nvarchar(max) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();

    CREATE TABLE #Scope (MemberId int NOT NULL PRIMARY KEY);

    IF (@MemberIdsJson IS NULL)
    BEGIN
        INSERT INTO #Scope (MemberId)
        SELECT m.MemberId FROM dbo.LTY_Member AS m WHERE m.PropertyId = @PropertyId;
    END
    ELSE
    BEGIN
        INSERT INTO #Scope (MemberId)
        SELECT DISTINCT CONVERT(int, [value])
        FROM   OPENJSON(@MemberIdsJson)
        WHERE  ISNUMERIC([value]) = 1;
    END

    ---- transactions -------------------------------------------------------
    /*  BillValue repeats across every point row for one order, so it is taken
        per OrderNo before being summed. Summing it directly would multiply a
        member's spend by however many point rows each order produced.           */
    CREATE TABLE #Orders
    (
        MemberId  int          NOT NULL,
        OrderNo   varchar(200) NOT NULL,
        OrderDate datetime     NOT NULL,
        BillValue decimal(18,4) NOT NULL,
        Outlet    varchar(50)  NULL,
        PRIMARY KEY (MemberId, OrderNo)
    );

    INSERT INTO #Orders (MemberId, OrderNo, OrderDate, BillValue, Outlet)
    SELECT t.MemberId,
           t.OrderNo,
           MIN(t.TxnDate),
           MAX(t.BillValue),
           MAX(t.OutletCode)
    FROM   dbo.LTY_MemberWisePointTransaction AS t
    INNER JOIN #Scope AS s ON s.MemberId = t.MemberId
    WHERE  t.PropertyId      = @PropertyId
      AND  t.TransactionType = 'G'
      AND  ISNULL(t.OrderNo, '') <> ''
    GROUP BY t.MemberId, t.OrderNo;

    ---- assemble -----------------------------------------------------------
    ;WITH Txn AS
    (
        SELECT o.MemberId,
               MAX(o.OrderDate)                       AS LastPurchaseAt,
               MIN(o.OrderDate)                       AS FirstPurchaseAt,
               COUNT(*)                               AS TransactionCount,
               SUM(o.BillValue)                       AS TotalSpend,
               CASE WHEN COUNT(*) = 0 THEN 0
                    ELSE SUM(o.BillValue) / COUNT(*) END AS AvgTransactionValue
        FROM   #Orders AS o
        GROUP BY o.MemberId
    ),
    LastOutlet AS
    (
        SELECT o.MemberId, o.Outlet,
               ROW_NUMBER() OVER (PARTITION BY o.MemberId ORDER BY o.OrderDate DESC) AS rn
        FROM   #Orders AS o
    ),
    /*  PointBalance is the STORED running balance on the member's newest
        transaction row, not a SUM of NoPoints - matching
        dbo.LTYM_fn_MemberPointsBalance exactly, including its clamp at zero.

        This distinction is not academic. Summing NoPoints disagrees with the
        running balance wherever a void has been recorded ('V' writes a
        compensating row whose sign does not simply cancel), and one member on
        this server already differs by 20 points. A segment built on the sum
        would select members whose portal shows a different number, and could
        promise points that LTYM_Reward_Redeem - which uses the function - then
        refuses to spend.                                                        */
    Balance AS
    (
        SELECT t.MemberId, t.PointsBalance,
               ROW_NUMBER() OVER (PARTITION BY t.MemberId ORDER BY t.Id DESC) AS rn
        FROM   dbo.LTY_MemberWisePointTransaction AS t
        INNER JOIN #Scope AS s ON s.MemberId = t.MemberId
        WHERE  t.PropertyId = @PropertyId
    ),
    Points AS
    (
        SELECT t.MemberId,
               SUM(CASE WHEN t.TransactionType = 'G' THEN t.NoPoints ELSE 0 END)        AS PointsEarned,
               SUM(CASE WHEN t.TransactionType = 'R' THEN -t.NoPoints ELSE 0 END)       AS PointsRedeemed,
               SUM(CASE WHEN t.TransactionType = 'E' THEN -t.NoPoints ELSE 0 END)       AS PointsExpired,
               -- Unexpired earned points falling due inside 30 days.
               SUM(CASE WHEN t.TransactionType = 'G'
                         AND t.ExpireDate > @now
                         AND t.ExpireDate <= DATEADD(day, 30, @now)
                        THEN t.NoPoints ELSE 0 END)                                     AS PointsExpiring30d
        FROM   dbo.LTY_MemberWisePointTransaction AS t
        INNER JOIN #Scope AS s ON s.MemberId = t.MemberId
        WHERE  t.PropertyId = @PropertyId
        GROUP BY t.MemberId
    ),
    Vouchers AS
    (
        SELECT c.MemberId,
               COUNT(*)                                                       AS VouchersIssued,
               SUM(CASE WHEN u.CouponId IS NOT NULL THEN 1 ELSE 0 END)        AS VouchersRedeemed,
               SUM(CASE WHEN u.CouponId IS NULL AND c.ExpireDate > @now
                        THEN 1 ELSE 0 END)                                    AS VouchersUnused,
               MAX(u.OrderDate)                                               AS LastRedemptionAt
        FROM   dbo.LTY_CouponMaster AS c
        INNER JOIN #Scope AS s ON s.MemberId = c.MemberId
        OUTER APPLY (
            SELECT TOP (1) x.CouponId, x.OrderDate
            FROM   dbo.LTY_CouponUsage AS x
            WHERE  x.CouponId = c.Id AND x.PropertyId = c.PropertyId AND x.IsUse = 1
        ) AS u
        WHERE  c.PropertyId = @PropertyId
        GROUP BY c.MemberId
    )
    MERGE dbo.LTYC_MemberMetrics AS tgt
    USING (
        SELECT s.MemberId,
               @PropertyId                            AS PropertyId,
               t.LastPurchaseAt,
               t.FirstPurchaseAt,
               ISNULL(t.TransactionCount, 0)          AS TransactionCount,
               ISNULL(t.TotalSpend, 0)                AS TotalSpend,
               ISNULL(t.AvgTransactionValue, 0)       AS AvgTransactionValue,
               lo.Outlet                              AS LastOutletCode,
               CASE WHEN ISNULL(b.PointsBalance, 0) < 0 THEN 0
                    ELSE ISNULL(b.PointsBalance, 0) END AS PointBalance,
               ISNULL(p.PointsEarned, 0)              AS PointsEarned,
               ISNULL(p.PointsRedeemed, 0)            AS PointsRedeemed,
               ISNULL(p.PointsExpired, 0)             AS PointsExpired,
               ISNULL(p.PointsExpiring30d, 0)         AS PointsExpiring30d,
               ISNULL(v.VouchersIssued, 0)            AS VouchersIssued,
               ISNULL(v.VouchersRedeemed, 0)          AS VouchersRedeemed,
               ISNULL(v.VouchersUnused, 0)            AS VouchersUnused,
               v.LastRedemptionAt
        FROM   #Scope AS s
        LEFT JOIN Txn        AS t  ON t.MemberId = s.MemberId
        LEFT JOIN LastOutlet AS lo ON lo.MemberId = s.MemberId AND lo.rn = 1
        LEFT JOIN Points     AS p  ON p.MemberId = s.MemberId
        LEFT JOIN Balance    AS b  ON b.MemberId = s.MemberId AND b.rn = 1
        LEFT JOIN Vouchers   AS v  ON v.MemberId = s.MemberId
    ) AS src
       ON tgt.MemberId = src.MemberId
     WHEN MATCHED THEN
          UPDATE SET PropertyId          = src.PropertyId,
                     LastPurchaseAt      = src.LastPurchaseAt,
                     FirstPurchaseAt     = src.FirstPurchaseAt,
                     TransactionCount    = src.TransactionCount,
                     TotalSpend          = src.TotalSpend,
                     AvgTransactionValue = src.AvgTransactionValue,
                     LastOutletCode      = src.LastOutletCode,
                     PointBalance        = src.PointBalance,
                     PointsEarned        = src.PointsEarned,
                     PointsRedeemed      = src.PointsRedeemed,
                     PointsExpired       = src.PointsExpired,
                     PointsExpiring30d   = src.PointsExpiring30d,
                     VouchersIssued      = src.VouchersIssued,
                     VouchersRedeemed    = src.VouchersRedeemed,
                     VouchersUnused      = src.VouchersUnused,
                     LastRedemptionAt    = src.LastRedemptionAt,
                     ComputedAt          = @now
     WHEN NOT MATCHED BY TARGET THEN
          INSERT (MemberId, PropertyId, LastPurchaseAt, FirstPurchaseAt, TransactionCount,
                  TotalSpend, AvgTransactionValue, LastOutletCode, PointBalance, PointsEarned,
                  PointsRedeemed, PointsExpired, PointsExpiring30d, VouchersIssued,
                  VouchersRedeemed, VouchersUnused, LastRedemptionAt, ComputedAt)
          VALUES (src.MemberId, src.PropertyId, src.LastPurchaseAt, src.FirstPurchaseAt, src.TransactionCount,
                  src.TotalSpend, src.AvgTransactionValue, src.LastOutletCode, src.PointBalance, src.PointsEarned,
                  src.PointsRedeemed, src.PointsExpired, src.PointsExpiring30d, src.VouchersIssued,
                  src.VouchersRedeemed, src.VouchersUnused, src.LastRedemptionAt, @now);

    DECLARE @affected int = @@ROWCOUNT;

    IF (@MemberIdsJson IS NULL)
    BEGIN
        MERGE dbo.LTYC_MetricsWatermark AS t
        USING (SELECT @PropertyId AS PropertyId) AS s ON t.PropertyId = s.PropertyId
         WHEN MATCHED THEN UPDATE SET LastFullRebuildAt = @now, LastRunAt = @now
         WHEN NOT MATCHED BY TARGET THEN
              INSERT (PropertyId, LastFullRebuildAt, LastRunAt) VALUES (@PropertyId, @now, @now);
    END

    DROP TABLE #Orders;
    DROP TABLE #Scope;

    SELECT @affected AS MembersUpdated;
END

GO

