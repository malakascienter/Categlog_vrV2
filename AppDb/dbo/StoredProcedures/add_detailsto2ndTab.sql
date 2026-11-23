

CREATE PROCEDURE add_detailsto2ndTab
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
		1,
		1,
		GETDATE(),
		GETDATE()
		

		)
		SELECT SCOPE_IDENTITY() AS Id
		SET @NewId = SCOPE_IDENTITY()
		SET @statusIN = 1;


			END
	
	COMMIT TRAN -- Transaction Success!
	SET @status = @statusIN
END TRY

BEGIN CATCH
	SET @status = -1;
SET @message = CAST(ERROR_NUMBER() AS VARCHAR(10)) + ' - ' + ERROR_MESSAGE() + ' - On Line ' + CAST(ERROR_LINE() AS VARCHAR(10))
	IF @@TRANCOUNT > 0
	ROLLBACK TRAN --RollBack in case of Error
END CATCH


END

GO

