-- =============================================
-- Author:		chiraj
-- Create date: 2020-7-15
-- Description: Tables_M_Delete
-- =============================================
CREATE PROCEDURE [dbo].[Tables_M_Delete]
	@TableId INT,
	@TablecategoryId INT,
	@UserId INT,
	@PropertyId INT

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
		IF EXISTS(SELECT 1 FROm BillHeader where  TableNo=(SELECT TableName FROm POS_TableList where TableID=@TableId) AND PropertyId=@PropertyId)       
		BEGIN  
			RAISERROR('Table already used ,You can not Delete the record',16,1)  
		END 
		ELSE
		BEGIN			
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'POS_TableList',@TableId
			-- end of audit trail	

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_TableList',@TableId,'POS','POSTTD','D',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			--DELETE FROM POS_TableList WHERE TableID = @TableId AND PropertyId=@PropertyId
			UPDATE POS_TableList SET IsUpload=0,MarkAsDelete=1 WHERE PropertyId=@PropertyId AND TableID=@TableId AND TableCategoryID=@TablecategoryId
			-- audit trail				
			SET @Remark = 'POS_TableList '+Cast(@TableId as VARCHAR(100))+' deleted.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'POS_TableList',@TableId,@UserId,'D',@Remark
			-- end of audit trail	
		END
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

