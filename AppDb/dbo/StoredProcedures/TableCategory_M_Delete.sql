-- =============================================
-- Author:		chiraj
-- Create date: 2020-7-7
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[TableCategory_M_Delete]
	@Id INT,
	@userId INT,
	@PropertyId INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
	DECLARE @Remark NVARCHAR(250)  
	SET NOCOUNT ON;
	IF EXISTS(SELECT 1 FROm BillHeader where  TableNo in(SELECT TableName FROm POS_TableList where TableCategoryID=@Id) AND PropertyId=@PropertyId)       
		BEGIN  
			RAISERROR('Table already used ,You can not Delete the record',16,1)  
		END 
		ELSE
		BEGIN
				-- audit trail    
			EXEC [dbo].[AuditTrail_InsertToHistory] 'POS_TableCategories',@Id  
			-- end of audit trail   

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_TableCategories',@Id,'POS','POSTCD','D',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
  
			--DELETE FROM POS_TableCategories WHERE TableCategoryID = @Id AND PropertyId=@PropertyId
			UPDATE 
			POS_TableCategories 
			SET IsUpload=0,MarkAsDelete=1
			WHERE PropertyId=@PropertyId AND TableCategoryID=@Id
   
  
			-- audit trail      
			SET @Remark = 'POS TableCategories '+ CONVERT(VARCHAR,@Id) +' deleted.';  
					EXEC [dbo].[AuditTrail_InsertTableChanges] 'POS_TableCategories',@Id,@UserId,'D',@Remark  
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

