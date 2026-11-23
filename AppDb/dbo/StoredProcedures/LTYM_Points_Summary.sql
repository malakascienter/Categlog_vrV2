
CREATE   PROCEDURE [dbo].[LTYM_Points_Summary]
    @MemberId   INT
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    DECLARE @MonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);

    SELECT
        CAST(dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId) AS DECIMAL(18,2)) AS CurrentBalance,
        CAST(ISNULL(SUM(CASE WHEN TransactionType = 'G' THEN NoPoints  END), 0) AS DECIMAL(18,2)) AS TotalEarned,
        CAST(ISNULL(SUM(CASE WHEN TransactionType = 'R' THEN -NoPoints END), 0) AS DECIMAL(18,2)) AS TotalRedeemed,
        CAST(ISNULL(SUM(CASE WHEN TransactionType = 'E' THEN -NoPoints END), 0) AS DECIMAL(18,2)) AS TotalExpired,
        CAST(ISNULL(SUM(CASE WHEN TransactionType = 'G' AND TxnDate >= @MonthStart THEN NoPoints  END), 0) AS DECIMAL(18,2)) AS MonthEarned,
        CAST(ISNULL(SUM(CASE WHEN TransactionType = 'R' AND TxnDate >= @MonthStart THEN -NoPoints END), 0) AS DECIMAL(18,2)) AS MonthRedeemed
    FROM   dbo.LTY_MemberWisePointTransaction
    WHERE  MemberId = @MemberId AND PropertyId = @PropertyId;
END

GO

