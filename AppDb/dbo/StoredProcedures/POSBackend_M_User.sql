
CREATE PROCEDURE [dbo].[POSBackend_M_User]  
@UserId INT,  
@Username NVARCHAR(20),   
@IsActive BIT,   
@CreatedOrEditedUserId INT,
@Operation CHAR(1),
@PropertyId INT
AS  
BEGIN  TRY
	SET NOCOUNT ON;  

	DECLARE @UserTableIDStr VARCHAR(50)
	
	IF @Operation='I' 
	BEGIN
		PRINT 1

	END  
	ELSE IF @Operation='U'  
	BEGIN  

	    UPDATE	Users 
	    SET		IsUpload = 0,
				IsActive = @IsActive,
				LastEditedUserId = @CreatedOrEditedUserId,
				PropertyId = @PropertyId
	    WHERE	Id = @UserId

		SET @UserTableIDStr = CONVERT(VARCHAR(50),@UserId)
		EXEC Insert_Sync_MasterDataTransferStatus 'User',@IsActive,@UserTableIDStr,@PropertyId



	END  
	ELSE IF @Operation='D'  
	BEGIN

		UPDATE	Users 
	    SET		IsUpload = 0,
				IsActive = @IsActive,
				LastEditedUserId = @CreatedOrEditedUserId,
				PropertyId = @PropertyId
	    WHERE	Id = @UserId

		SET @UserTableIDStr  = CONVERT(VARCHAR(50),@UserId)
		EXEC Insert_Sync_MasterDataTransferStatus 'User',@IsActive,@UserTableIDStr,@PropertyId

	END
	

  
  
END TRY 
BEGIN CATCH
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

