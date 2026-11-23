CREATE PROCEDURE [dbo].[SP_Update_Common_Reject_For_BOQ]


	@ApprovedDate DATE,
	@RequestHeaderID INT,
	@TransactionID INT,
	@UserProfileID INT,
	@ApprovalLevelID INT
AS
BEGIN
	SET NOCOUNT ON;
	 IF @TransactionID=52
		BEGIN
			UPDATE dbo.ApprovalLogs
			
			SET DocStatus = 'X',
				ApprovalDate = @ApprovedDate,
				IsComplete=1,
				ApprovalUserID = @UserProfileID
			WHERE  TransactionID = @TransactionID
			AND TransactionHeaderID=@RequestHeaderID 
			AND ApprovalLevelID = @ApprovalLevelID


			UPDATE dbo.BOQHeaders
			SET BOQStatus = 2,
				Approve = 1
	WHERE Id = @RequestHeaderID


		END
    

	

END

GO

