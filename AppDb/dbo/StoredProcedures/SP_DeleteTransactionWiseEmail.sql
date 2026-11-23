-- [dbo].[SP_DeleteTransactionWiseEmail] 1,2,5242,1
CREATE PROCEDURE [dbo].[SP_DeleteTransactionWiseEmail]
@PropertyID INT,@LocationID INT, @UserID INT = -999, @TransactionID INT = -999, @Id INT
AS
BEGIN
BEGIN TRY 
IF(@PropertyID IS NULL OR @PropertyID =0)
		BEGIN
			RAISERROR('Property Invalid',16,1)
			ROLLBACK TRANSACTION
		END
		IF(@LocationID IS NULL )
		BEGIN
			RAISERROR('Location Invalid',16,1)
			ROLLBACK TRANSACTION
		END
		IF(@TransactionID IS NULL )
		BEGIN
			RAISERROR('Transaction Type Invalid',16,1)
			ROLLBACK TRANSACTION
		END
		IF(@UserID IS NULL )
		BEGIN
			RAISERROR('User Invalid',16,1)
			ROLLBACK TRANSACTION
		END

--SELECT * FROM UserWiseApproveLevels

	IF NOT EXISTS(SELECT 1 FROM dbo.TransactionWiseEmails 
	WHERE PropertyID = @PropertyID AND LocationID = @LocationID AND TransactionType= (SELECT TOP 1 Code FROM TransactionTypes WHERE Id = @TransactionID)
	AND UserID = @UserID)
	BEGIN
			RAISERROR('Not found',16,1)
			ROLLBACK TRANSACTION
	END

	DELETE FROM dbo.TransactionWiseEmails 
	WHERE PropertyID = @PropertyID AND LocationID = @LocationID AND TransactionType= (SELECT TOP 1 Code FROM TransactionTypes WHERE Id = @TransactionID)
	AND UserID = @UserID
	
	IF NOT EXISTS(SELECT 1 FROM dbo.TransactionWiseEmails 
	WHERE PropertyID = @PropertyID AND LocationID = @LocationID  AND TransactionType= (SELECT TOP 1 Code FROM TransactionTypes WHERE Id = @TransactionID))
	BEGIN
		UPDATE TransactionTypes
		SET IsMailNotification = 0
		WHERE Id = @TransactionID
	END

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
	
	
END

GO

