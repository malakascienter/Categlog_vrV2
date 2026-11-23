

CREATE PROCEDURE [dbo].[SP_Save_AltGroupItemDetails]
	@ID int,
	@GroupID int,
	@ItemID int,
	@IPAddress varchar(max),
	@CreatedUserID int,
	@LastModUserID int,
	@CreatedDate datetime,
	@LastModDate datetime,
	@status[int] output,
	@NewId[int] output,
	@message NVARCHAR(max) OUTPUT
AS

DECLARE			@statusIN[int]
				SET @statusIN = 0;
				SET  @NewId =0
				SET  @message = ''


BEGIN
BEGIN TRY
BEGIN TRANSACTION
	BEGIN
	
	INSERT INTO AltItemGroupDetails(

		[GroupID],
		[ItemID],
		[IPAddress],
		[CreatedUserID],
		[LastModUserID],
		[CreatedDate],
		[LastModDate]
		
		)
		VALUES
		(
		@GroupID,
		@ItemID,
		@IPAddress,
		@CreatedUserID,
		@LastModUserID,
		GETDATE(),
		GETDATE()
		

		)

----------------------- 12.02.2024-----------------------------------------
		IF(@CreatedUserID = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 ); 
			RAISERROR('User ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
----------------------------------------------------------------------------
		SELECT SCOPE_IDENTITY() AS Id
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;
		EXEC Inventry_AuditTail_WriteToLog 'AltItemGroupDetails', @NewId, 'INV', 'AIGDI', 'I', @CreatedUserID,0, '', ''

			END
	
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY

BEGIN CATCH
	SET @status = -1;
--SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
set @message = 'Error Occured: '+ ERROR_MESSAGE();
Raiserror(@message,16,1)
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH


END

GO

