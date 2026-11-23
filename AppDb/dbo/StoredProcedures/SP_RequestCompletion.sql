

CREATE  PROCEDURE [dbo].[SP_RequestCompletion] 
	@UserProfileId		int = 0,
	@Id			INT = 0
AS
BEGIN
-----------------------------------------------------------------
BEGIN TRY 
---------------------
	IF(@UserProfileId = 0)
	BEGIN
		RAISERROR('User ID Invalid, Please Log In Again',16,1)
		ROLLBACK TRANSACTION
	END

	IF(@Id = 0)
	BEGIN
		RAISERROR('Invalid Request',16,1)
		ROLLBACK TRANSACTION
	END

----------------------
	UPDATE RequestHeaders SET DocumentStatus = 'C',UserProfileID = @UserProfileId WHERE Id = @Id

	DECLARE @TransactionType CHAR(4)

	SELECT @TransactionType = RequestType
	FROM RequestHeaders
	WHERE Id = @Id

	INSERT INTO TransactionStatus_Log(HeaderID, TransactionType, SysDate, Status, UserID, Module)
	SELECT @Id,@TransactionType,GETDATE(),'Complete',@UserProfileId,'Completion View'

END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
-----------------------------------------------------------------

END

GO

