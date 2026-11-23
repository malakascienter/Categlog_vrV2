
CREATE PROCEDURE [dbo].[ItemPriceChangeLog_M_Update]
	@OutLetWiseMenuItemID INT,
	@UserId INT,
	@PropertyId INT,
	@IsActive BIT

AS
BEGIN

	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_OutletWiseMenuItemPriceChangeLog',@OutLetWiseMenuItemID,'POS','POSPCL','U',@UserId,'','','','','',@PropertyId

			UPDATE POS_OutletWiseMenuItemPriceChangeLog SET IsActive=@IsActive WHERE OutLetWiseMenuItemID=@OutLetWiseMenuItemID
			
			EXEC Insert_Sync_MasterDataTransferStatus 'ItemPriceChangeLog',@IsActive,@OutLetWiseMenuItemID,@PropertyId

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH	
		ROLLBACK TRANSACTION
		DECLARE @Error NVARCHAR(MAX)
		SET @Error=ERROR_MESSAGE()
		RAISERROR(@Error,16,1)	
	END CATCH
    
END

GO

