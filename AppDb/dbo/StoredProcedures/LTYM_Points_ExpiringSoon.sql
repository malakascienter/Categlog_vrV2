
CREATE   PROCEDURE [dbo].[LTYM_Points_ExpiringSoon]
    @MemberId INT,
    @Months   INT = 3
AS
BEGIN
    SET NOCOUNT ON;

    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);

    IF @Months IS NULL OR @Months < 1 SET @Months = 3;
    IF @Months > 24 SET @Months = 24;

    DECLARE @FromDate DATETIME = GETDATE();
    DECLARE @ToDate   DATETIME = DATEADD(MONTH, @Months, @FromDate);

    SELECT MPT.Id,
           MPT.TxnDate,
           MPT.ExpireDate,
           CASE WHEN DATEDIFF(DAY, GETDATE(), MPT.ExpireDate) < 0
                THEN 0 ELSE DATEDIFF(DAY, GETDATE(), MPT.ExpireDate) END AS DaysRemaining,
           MPT.NoPoints        AS Points,
           MPT.OrderNo,
           MPT.OutletCode,
           L.Description       AS OutletName,
           MPT.Remark
    FROM   dbo.LTY_MemberWisePointTransaction AS MPT
    LEFT JOIN dbo.Location AS L ON L.Code = MPT.OutletCode
    WHERE  MPT.MemberId        = @MemberId
      AND  MPT.PropertyId      = @PropertyId
      AND  MPT.TransactionType = 'G'
      AND  MPT.NoPoints        > 0
      AND  MPT.ExpireDate BETWEEN @FromDate AND @ToDate
    ORDER BY MPT.ExpireDate, MPT.Id;

    SELECT @MemberId AS MemberId,
           @Months   AS Months,
           @FromDate AS FromDate,
           @ToDate   AS ToDate,
           CAST(ISNULL((SELECT SUM(MPT.NoPoints)
                        FROM   dbo.LTY_MemberWisePointTransaction AS MPT
                        WHERE  MPT.MemberId        = @MemberId
                          AND  MPT.PropertyId      = @PropertyId
                          AND  MPT.TransactionType = 'G'
                          AND  MPT.NoPoints        > 0
                          AND  MPT.ExpireDate BETWEEN @FromDate AND @ToDate), 0) AS DECIMAL(18,2)) AS TotalExpiringPoints,
           CAST(dbo.LTYM_fn_MemberPointsBalance(@MemberId, @PropertyId) AS DECIMAL(18,2)) AS CurrentBalance;
END

GO

