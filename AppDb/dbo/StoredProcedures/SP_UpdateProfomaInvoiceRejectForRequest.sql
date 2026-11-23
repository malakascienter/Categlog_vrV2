CREATE PROCEDURE [dbo].[SP_UpdateProfomaInvoiceRejectForRequest]
	@ApprovedDate DATE,
	@RequestHeaderID INT,
	@TransactionID INT,
	@UserProfileID INT,
	@ApprovalLevelID INT
AS
BEGIN
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	UPDATE dbo.ApprovalLogs
			
		SET DocStatus = 'X',
			ApprovalDate = @ApprovedDate,
			IsComplete=1,
			ApprovalUserID = @UserProfileID
	WHERE  TransactionID = @TransactionID
	AND TransactionHeaderID=@RequestHeaderID 
	AND ApprovalLevelID = @ApprovalLevelID
	
	
	
	UPDATE dbo.ProfomaInvoiceHeaders
			SET DocumentStatus = 'X',
				IsApproved = 0
	WHERE Id = @RequestHeaderID

END

GO

