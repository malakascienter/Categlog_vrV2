
CREATE   PROCEDURE [dbo].[LTYM_Orders_SelectPaged]
    @MemberId   INT,
    @Page       INT = 1,
    @PageSize   INT = 20
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    IF @Page < 1 SET @Page = 1;
    IF @PageSize < 1 OR @PageSize > 100 SET @PageSize = 20;

    SELECT MPT.OrderNo,
           MIN(MPT.TxnDate)                                                    AS OrderDate,
           MIN(MPT.CreatedDateTime)                                            AS CreatedDateTime,
           MAX(MPT.BillValue)                                                  AS BillValue,
           MAX(L.Description)                                                  AS OutletName,
           CAST(ISNULL(SUM(CASE WHEN MPT.TransactionType = 'G' THEN MPT.NoPoints  END), 0) AS DECIMAL(18,2)) AS PointsEarned,
           CAST(ISNULL(SUM(CASE WHEN MPT.TransactionType = 'R' THEN -MPT.NoPoints END), 0) AS DECIMAL(18,2)) AS PointsRedeemed
    FROM   dbo.LTY_MemberWisePointTransaction AS MPT
    LEFT JOIN dbo.Location AS L ON L.Code = MPT.OutletCode
    WHERE  MPT.MemberId   = @MemberId
      AND  MPT.PropertyId = @PropertyId
      AND  ISNULL(MPT.OrderNo, '') <> ''
    GROUP BY MPT.OrderNo
    ORDER BY MIN(MPT.TxnDate) DESC, MPT.OrderNo DESC
    OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*)
    FROM  (SELECT MPT.OrderNo
           FROM   dbo.LTY_MemberWisePointTransaction AS MPT
           WHERE  MPT.MemberId   = @MemberId
             AND  MPT.PropertyId = @PropertyId
             AND  ISNULL(MPT.OrderNo, '') <> ''
           GROUP BY MPT.OrderNo) AS O;
END

GO

