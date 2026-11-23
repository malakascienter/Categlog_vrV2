-- =============================================
-- Author:		chiraj
-- Create date: 2020-7-15
-- Description: Tables_M_Delete
-- =============================================
CREATE PROCEDURE [dbo].[TablesStatus_M_Update]
	@TableId INT,
	@TablecategoryId INT,
	@UserId INT,
	@PropertyId INT,
	@IsActive BIT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	--check billheader befoire delete
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @Remark NVARCHAR(250)
		DECLARE @CatgId INT	
		
			EXEC [dbo].[AuditTrail_InsertToHistory] 'POS_TableList',@TableId

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_TableList',@TableId,'POS','POSTTU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			UPDATE POS_TableList SET IsUpload=0,IsActive=@IsActive WHERE PropertyId=@PropertyId AND TableID=@TableId AND TableCategoryID=@TablecategoryId
			UPDATE POS_TableCategories SET IsUpload = 0 WHERE TableCategoryID = @TablecategoryId
			SET @Remark = 'POS_TableList '+Cast(@TableId as VARCHAR(100))+' deleted.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'POS_TableList',@TableId,@UserId,'D',@Remark


			EXEC Insert_Sync_MasterDataTransferStatus 'Table',@IsActive,@TableId,@PropertyId

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

