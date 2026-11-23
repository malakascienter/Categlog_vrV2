
-- =============================================  
-- Author:  Banu  
-- Create date: 02/11/2018  
-- Description: Save & Update for Item Category  
-- =============================================  
CREATE PROCEDURE [dbo].[ItemCategory_M_Save]  
	@Id INT,  
	@Code VARCHAR(3),  
	@Name VARCHAR(50),  
	@IsActive BIT,  
	@Operation VARCHAR(1),  
	@UserId INT  ,
	@PropertyId INT
AS  
BEGIN   
	SET NOCOUNT OFF;  
	DECLARE @Remark NVARCHAR(250)  
  
	IF(@Operation = 'I')  
	BEGIN  
		IF EXISTS(SELECT 1 FROM ItemCategory WHERE PropertyId=@PropertyId AND (Code = @Code OR Name = @Name))  
		BEGIN  
			RAISERROR('Code or Name is already exists.',16,1)  
		END  
		ELSE  
		BEGIN  
			-- audit trail    
			EXEC [dbo].[AuditTrail_InsertToHistory] 'ItemCategory',@Code  
			-- end of audit trail   
  
			INSERT INTO ItemCategory(Code,Name,IsActive,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)   
			VALUES(@Code,@Name,@IsActive,@PropertyId,0 ,@UserId,GETDATE())
  
			-- audit trail      
			SET @Remark = 'Item category '+@Code+', '+@Name+' created.';  
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'Category',@Code,@UserId,'I',@Remark  
			-- end of audit trail   
		END  
	END  
	ELSE    
	BEGIN  
		-- audit trail    
		EXEC [dbo].[AuditTrail_InsertToHistory] 'ItemCategory',@Code  
		-- end of audit trail   
  
		UPDATE ItemCategory 
		SET 
		Name = @Name,
		IsActive = @IsActive,
		PropertyId=@PropertyId,
		UpdatedUserId=@UserId,
		UpdatedDateTime=GETDATE(),
		IsUpload=0
		WHERE Id = @Id AND Code = @Code AND PropertyId=@PropertyId
  
		-- audit trail      
		SET @Remark = 'Item category '+@Code+', '+@Name+' updated.';  
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'ItemCategory',@Code,@UserId,'U',@Remark  
		-- end of audit trail   
	END												 
END

GO

