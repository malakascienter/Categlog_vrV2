
CREATE   PROCEDURE [dbo].[LTYM_Order_SelectByOrderNo]
    @MemberId   INT,
    @OrderNo    VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;


    -- PropertyId is not part of this module's interface; it comes from the member row.
    DECLARE @PropertyId INT = (SELECT TOP (1) PropertyId FROM dbo.LTY_Member WHERE MemberId = @MemberId);
    SELECT MPT.Id,
           MPT.OrderNo,
           MPT.TxnDate,
           MPT.CreatedDateTime,
           MPT.TransactionType,
           MPT.NoPoints,
           MPT.PointsBalance,
           MPT.BillValue,
           L.Description AS OutletName,
           MPT.Remark
    FROM   dbo.LTY_MemberWisePointTransaction AS MPT
    LEFT JOIN dbo.Location AS L ON L.Code = MPT.OutletCode
    WHERE  MPT.MemberId   = @MemberId
      AND  MPT.PropertyId = @PropertyId
      AND  MPT.OrderNo    = @OrderNo
    ORDER BY MPT.Id;
END

GO

