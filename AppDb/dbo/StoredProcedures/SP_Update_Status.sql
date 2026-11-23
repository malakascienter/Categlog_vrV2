
CREATE PROCEDURE [dbo].[SP_Update_Status]
@OrderNo varchar(6),
@OrderDate DATETIME,
@Outlet VARCHAR(3),
@PropertyId INT,
@Status BIT,
@Type VARCHAR(2)
AS
BEGIN


IF( @Type = 'S' )
BEGIN

	UPDATE POS_EBillOrder
	SET IsEBillSend = @Status
	WHERE OrderNo =  @OrderNo AND  CONVERT(date,OrderDate,103) = CONVERT(date,@OrderDate,103)  AND Outlet =  @Outlet AND PropertyId = @PropertyId

END
ELSE
BEGIN

 UPDATE POS_EBillOrder
 SET IsEBillSendFail = 1
 WHERE OrderNo =  @OrderNo AND CONVERT(date,OrderDate,103) = CONVERT(date,@OrderDate,103) AND Outlet =  @Outlet AND PropertyId = @PropertyId

END
	
	



END

GO

