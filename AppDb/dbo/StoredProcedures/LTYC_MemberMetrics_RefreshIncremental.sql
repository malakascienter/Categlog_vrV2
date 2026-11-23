/*  Recompute only the members touched since the last run.

    Watermarks are identity values rather than timestamps, deliberately: an
    identity is monotonic and never re-used, whereas a row inserted with an
    earlier TxnDate after the watermark moved would be skipped forever.

    Members are recomputed in full rather than adjusted by delta. Recomputing one
    member is cheap and always correct; incrementally adjusting an average or a
    "last purchase" would drift the moment a row was voided or backdated.        */
CREATE PROCEDURE dbo.LTYC_MemberMetrics_RefreshIncremental
    @PropertyId int,
    @MaxMembers int = 5000
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @now datetime2(3) = SYSUTCDATETIME();

    DECLARE @lastTxn   int = 0;
    DECLARE @lastCoupon int = 0;
    DECLARE @lastUsage int = 0;

    SELECT @lastTxn    = LastPointTransId,
           @lastCoupon = LastCouponId,
           @lastUsage  = LastCouponUsageId
    FROM   dbo.LTYC_MetricsWatermark
    WHERE  PropertyId = @PropertyId;

    DECLARE @newTxn    int = ISNULL((SELECT MAX(Id) FROM dbo.LTY_MemberWisePointTransaction WHERE PropertyId = @PropertyId), 0);
    DECLARE @newCoupon int = ISNULL((SELECT MAX(Id) FROM dbo.LTY_CouponMaster WHERE PropertyId = @PropertyId), 0);
    DECLARE @newUsage  int = ISNULL((SELECT MAX(Id) FROM dbo.LTY_CouponUsage WHERE PropertyId = @PropertyId), 0);

    CREATE TABLE #Touched (MemberId int NOT NULL PRIMARY KEY);

    INSERT INTO #Touched (MemberId)
    SELECT DISTINCT t.MemberId
    FROM   dbo.LTY_MemberWisePointTransaction AS t
    WHERE  t.PropertyId = @PropertyId AND t.Id > @lastTxn;

    INSERT INTO #Touched (MemberId)
    SELECT DISTINCT c.MemberId
    FROM   dbo.LTY_CouponMaster AS c
    WHERE  c.PropertyId = @PropertyId AND c.Id > @lastCoupon
      AND  c.MemberId IS NOT NULL
      AND  NOT EXISTS (SELECT 1 FROM #Touched x WHERE x.MemberId = c.MemberId);

    -- A redemption changes the member's voucher counts even though no new
    -- coupon or transaction row was created for them.
    INSERT INTO #Touched (MemberId)
    SELECT DISTINCT c.MemberId
    FROM   dbo.LTY_CouponUsage AS u
    INNER JOIN dbo.LTY_CouponMaster AS c ON c.Id = u.CouponId
    WHERE  u.PropertyId = @PropertyId AND u.Id > @lastUsage
      AND  c.MemberId IS NOT NULL
      AND  NOT EXISTS (SELECT 1 FROM #Touched x WHERE x.MemberId = c.MemberId);

    DECLARE @count int = (SELECT COUNT(*) FROM #Touched);

    -- A very large backlog is left for the nightly full rebuild rather than
    -- turned into one enormous statement.
    IF (@count > @MaxMembers)
    BEGIN
        DROP TABLE #Touched;
        SELECT 0 AS MembersUpdated, @count AS Pending, 1 AS DeferredToFullRebuild;
        RETURN;
    END

    DECLARE @ids nvarchar(max) = (SELECT MemberId AS [value] FROM #Touched FOR JSON PATH);

    DECLARE @updated int = 0;

    IF (@count > 0)
    BEGIN
        DECLARE @Result TABLE (MembersUpdated int);
        INSERT INTO @Result EXEC dbo.LTYC_MemberMetrics_Rebuild @PropertyId = @PropertyId, @MemberIdsJson = @ids;
        SELECT @updated = MembersUpdated FROM @Result;
    END

    MERGE dbo.LTYC_MetricsWatermark AS t
    USING (SELECT @PropertyId AS PropertyId) AS s ON t.PropertyId = s.PropertyId
     WHEN MATCHED THEN
          UPDATE SET LastPointTransId = @newTxn, LastCouponId = @newCoupon,
                     LastCouponUsageId = @newUsage, LastRunAt = @now
     WHEN NOT MATCHED BY TARGET THEN
          INSERT (PropertyId, LastPointTransId, LastCouponId, LastCouponUsageId, LastRunAt)
          VALUES (@PropertyId, @newTxn, @newCoupon, @newUsage, @now);

    DROP TABLE #Touched;

    SELECT @updated AS MembersUpdated, 0 AS Pending, 0 AS DeferredToFullRebuild;
END

GO

