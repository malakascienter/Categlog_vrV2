CREATE PROCEDURE [dbo].[MenuItemWiseModifiers_M_Save]  
	@ID					INT,   
	@MainMenuCode		VARCHAR(6),   
	@ActionID			INT,  
	@ModifierMenuJson	NVARCHAR(MAX), 
	@PropertyId			INT,
	@UserId				INT
AS  
BEGIN
	BEGIN TRANSACTION  
	BEGIN TRY
		BEGIN
			DELETE FROM MenuItemWiseModifier  
			WHERE MainMenuCode = @MainMenuCode AND ActionID = @ActionID
  
			INSERT INTO MenuItemWiseModifier(MainMenuCode,ModifierMenuCode,SeqNo,ActionID,PropertyId,MaxQty)  
			 SELECT @MainMenuCode,ModifierMenuCode,SeqNo,@ActionID  ,@PropertyId, ISNULL(MaxQty, 0) 
			 FROM   
			 OpenJson(@ModifierMenuJson)  
			 WITH  
			 (  
			 ModifierMenuCode VARCHAR(6) '$.ItemCode',  
			 SeqNo INT '$.SeqNo',
			 MaxQty   NUMERIC(18,2) '$.MaxQty'
			 ) 

			 UPDATE MAINMENU 
			 SET IsUpload = 0
			 WHERE ItemCode  = @MainMenuCode and PropertyId = @PropertyId

			 DECLARE @IsActive BIT
			 SELECT @IsActive = Active FROM MainMenu
			 WHERE ItemCode  = @MainMenuCode and PropertyId = @PropertyId 


			 EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@MainMenuCode,@PropertyId

		END
	COMMIT TRANSACTION 
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		DECLARE @ERR VARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR (@ERR, 16, 1)
	END CATCH
END

GO

