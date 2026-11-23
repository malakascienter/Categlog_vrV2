
CREATE   PROCEDURE [dbo].[LTYM_Dashboard_Summary]
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

    ;WITH Totals AS
    (
        SELECT
            SUM(CASE WHEN TransactionType = 'G' THEN NoPoints  ELSE 0 END) AS TotalEarned,
            SUM(CASE WHEN TransactionType = 'R' THEN -NoPoints ELSE 0 END) AS TotalRedeemed,
            SUM(CASE WHEN TransactionType = 'E' THEN -NoPoints ELSE 0 END) AS TotalExpired,
            SUM(CASE WHEN TransactionType = 'G' AND TxnDate >= @MonthStart THEN NoPoints  ELSE 0 END) AS MonthEarned,
            SUM(CASE WHEN TransactionType = 'R' AND TxnDate >= @MonthStart THEN -NoPoints ELSE 0 END) AS MonthRedeemed,
            COUNT(CASE WHEN TransactionType = 'G' THEN 1 END) AS TotalVisits,
            COUNT(CASE WHEN TransactionType = 'G' AND TxnDate >= @MonthStart THEN 1 END) AS MonthVisits
        FROM   dbo.LTY_MemberWisePointTransaction
        WHERE  MemberId = @MemberId AND PropertyId = @PropertyId
    )
    SELECT
        M.MembershipCode                                    AS MembershipNo,
        M.FirstName,
        M.LastName,
        T.TierName                                          AS Tier,
        M.CreatedDate                                       AS MemberSince,
        CAST(dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId) AS DECIMAL(18,2)) AS PointsBalance,
        CAST(ISNULL(X.TotalEarned,   0) AS DECIMAL(18,2))   AS TotalEarned,
        CAST(ISNULL(X.TotalRedeemed, 0) AS DECIMAL(18,2))   AS TotalRedeemed,
        CAST(ISNULL(X.TotalExpired,  0) AS DECIMAL(18,2))   AS TotalExpired,
        CAST(ISNULL(X.MonthEarned,   0) AS DECIMAL(18,2))   AS MonthEarned,
        CAST(ISNULL(X.MonthRedeemed, 0) AS DECIMAL(18,2))   AS MonthRedeemed,
        ISNULL(X.TotalVisits, 0)                            AS TotalVisits,
        ISNULL(X.MonthVisits, 0)                            AS MonthVisits,
        (SELECT COUNT(*)
         FROM   dbo.LTY_CouponMaster CM
         WHERE  CM.MemberId   = @MemberId
           AND  CM.PropertyId = @PropertyId
           AND  CM.ExpireDate > GETDATE()
           AND  NOT EXISTS (SELECT 1 FROM dbo.LTY_CouponUsage CU
                            WHERE CU.CouponId = CM.Id AND CU.IsUse = 1)) AS ActiveCoupons
    FROM   dbo.LTY_Member AS M
    LEFT JOIN dbo.LTY_Tier AS T ON T.TierId = M.TierId AND T.PropertyId = M.PropertyId
    LEFT JOIN Totals AS X ON 1 = 1
    WHERE  M.MemberId   = @MemberId
      AND  M.PropertyId = @PropertyId;
END

GO

