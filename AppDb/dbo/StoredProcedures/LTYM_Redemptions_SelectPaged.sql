
CREATE   PROCEDURE [dbo].[LTYM_Redemptions_SelectPaged]
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

    SELECT MPT.Id,
           MPT.TxnDate,
           MPT.CreatedDateTime,
           MPT.TransactionType,
           MPT.NoPoints,
           MPT.PointsBefore,
           MPT.PointsBalance,
           MPT.BillValue,
           MPT.OrderNo,
           L.Description AS OutletName,
           MPT.Remark
    FROM   dbo.LTY_MemberWisePointTransaction AS MPT
    LEFT JOIN dbo.Location AS L ON L.Code = MPT.OutletCode
    WHERE  MPT.MemberId   = @MemberId
      AND  MPT.PropertyId = @PropertyId
      AND  MPT.TransactionType = 'R'
    ORDER BY MPT.Id DESC
    OFFSET (@Page - 1) * @PageSize ROWS FETCH NEXT @PageSize ROWS ONLY;

    SELECT COUNT(*)
    FROM   dbo.LTY_MemberWisePointTransaction AS MPT
    WHERE  MPT.MemberId   = @MemberId
      AND  MPT.PropertyId = @PropertyId
      AND  MPT.TransactionType = 'R';
END

GO

