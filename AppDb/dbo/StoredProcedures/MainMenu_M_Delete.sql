
CREATE PROCEDURE [dbo].[MainMenu_M_Delete]  
 @Id		INT,  
@UserId	INT,
@PropertyId INT
AS  
BEGIN  
	BEGIN TRY
		DECLARE @Remark NVARCHAR(250)	 
		IF EXISTS(SELECT 1 FROm BillTrans where MainMenuCode=(SELECT ItemCode FROM MainMenu WHERE Id=@Id AND PropertyId=@PropertyId))   
		BEGIN  
			RAISERROR('MenuItem already used ,You can not Delete the record',16,1)  
		END 
		ELSE
		BEGIN
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'MainMenu',@Id
			-- end of audit trail	

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'MainMenu',@Id,'POS','POSMMD','D',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------
			
			--DELETE FROM MainMenu  WHERE Id = @Id  AND PropertyId=@PropertyId

			UPDATE MainMenu
			SET Active = 0,
				IsUpload = 0
			WHERE ID = @Id

			-- audit trail				
			SET @Remark = 'MainMenu '+CAST(@Id as Nvarchar(50))+' deleted.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'MainMenu',@Id,@UserId,'D',@Remark
			-- end of audit trail	
		END
	END TRY

	BEGIN CATCH	
		DECLARE @Error NVARCHAR(MAX)
		SET @Error=ERROR_MESSAGE()
		RAISERROR(@Error,16,1)	
	END CATCH
END

GO

