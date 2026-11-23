CREATE PROCEDURE [dbo].[SP_ChekApprovelsForRequest_ProfomaInv]
	@PropertyID			INT,
	@LocationID int , 
	@TransactionID int, 
	@TransactionHeaderID int
AS
BEGIN
	SET NOCOUNT ON;

	if (select COUNT(*) from dbo.ApprovalLogs
	where PropertyID=@PropertyID and LocationID=@LocationID 
	and TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
	and DocStatus <>'C')=0
	BEGIN
		
		/*Profoma Invoice doesn't required document status -> Chandimal Aiya 21-01-2016*/

		UPDATE ProfomaInvoiceHeaders SET IsApproved = 1 ,
											DocumentStatus = 'P'
		WHERE  Id = @TransactionHeaderID
		
		UPDATE dbo.RequestHeaders SET IsApproved = 1 WHERE Id = @TransactionHeaderID
	END
	else if (select COUNT(*) from dbo.ApprovalLogs
		where PropertyID=@PropertyID and LocationID=@LocationID 
		and TransactionHeaderID= @TransactionHeaderID and TransactionID = @TransactionID 
		and DocStatus ='X')>0
	BEGIN
		
		UPDATE ProfomaInvoiceHeaders SET IsApproved = 0 ,
											DocumentStatus = 'X'
		WHERE  Id = @TransactionHeaderID

	END
END

GO

