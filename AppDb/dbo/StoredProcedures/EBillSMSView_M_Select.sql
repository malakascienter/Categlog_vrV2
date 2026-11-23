
CREATE PROCEDURE [dbo].[EBillSMSView_M_Select]
	@OrderId VARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 

SELECT BillDetails FROM [EBillSMSView] WHERE OrderId = @OrderId
END

GO

