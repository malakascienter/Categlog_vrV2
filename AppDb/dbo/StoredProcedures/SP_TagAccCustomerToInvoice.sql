
CREATE PROCEDURE [dbo].[SP_TagAccCustomerToInvoice]
	@OrderNo VARCHAR(20),
	@PropertyId INT,
	@Outlet VARCHAR(10),
	@OrderDate DATE,
	@AccCustomer VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE BillHeader
	SET  CustomerCode = @AccCustomer
	where OrderNo = @OrderNo and OrderDate = @OrderDate AND Outlet = @Outlet and PropertyId = @PropertyId
   
END

GO

