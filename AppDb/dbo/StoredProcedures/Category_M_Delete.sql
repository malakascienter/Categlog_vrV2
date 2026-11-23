

-- =============================================
-- Author:		Chiraj
-- Create date: 2018-07-23
-- Description:	Category_M_Delete
-- =============================================
CREATE  PROCEDURE [dbo].[Category_M_Delete]
@Code		VARCHAR(6),
@UserId	INT,
@PropertyId INT
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @Remark NVARCHAR(250)
		DECLARE @CatgId INT	
		IF EXISTS(SELECT 1 FROm MainMenu where Category=@Code AND PropertyId=@PropertyId)       
		BEGIN  
			RAISERROR('Category already used ,You can not Delete the record',16,1)  
		END 
		ELSE
		BEGIN
			SELECT @CatgId = CatgId FROM Category WHERE Code = @Code AND  PropertyId=@PropertyId
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'Category',@CatgId
			-- end of audit trail	
			DELETE FROM Category WHERE Code = @Code AND PropertyId=@PropertyId
			--UPDATE MainMenu SET IsUpload=0 WHERE Category=@Code AND PropertyId=@PropertyId
			-- audit trail				
			SET @Remark = 'Category '+@Code+' deleted.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'Category',@CatgId,@UserId,'D',@Remark
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

