
-- =============================================  
-- Author:  Chiraj  
-- Create date: 2017-7-25  
-- Description: Save PosItemTypes  
-- =============================================  
CREATE PROCEDURE [dbo].[PosItemTypes_M_Save]   
@Operation CHAR(1),  
@Code CHAR(1),  
@Name VARCHAR(50),
@IsActive BIT,
@UserId	INT,
@PropertyId INT
AS  
BEGIN    
	DECLARE @Remark NVARCHAR(250)
	DECLARE @Id INT	
	SET NOCOUNT ON;  
	IF @Operation ='I'   
	BEGIN  
		SELECT @Id = Id FROM POSItemTypes WHERE Code = @Code AND PropertyId=@PropertyId

		IF EXISTS (SELECT 1 FROM POSItemTypes WHERE PropertyId=@PropertyId AND (Code=@Code or Name=@Name))
		BEGIN
			RAISERROR('Cannot insert duplicate code or Name for PosItem Types.',16,1)  
		END
		ELSE
		BEGIN
			-- audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'POSItemTypes',@Id
			-- end of audit trail	

			INSERT INTO POSItemTypes(Code,Name,IsActive,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)  
			VALUES(@Code,@Name,@IsActive,@PropertyId,0,@UserId,GETDATE())

			-- audit trail				
			SET @Remark = 'POS item types '+ @Code +', '+ @Name +' created.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'POSItemTypes',@Id,@UserId,'I',@Remark
			-- end of audit trail	
		END    
	END  
	ELSE IF @Operation ='U'  
	BEGIN  
		SELECT @Id = Id FROM POSItemTypes WHERE Code = @Code AND PropertyId=@PropertyId
		-- audit trail	 
		EXEC [dbo].[AuditTrail_InsertToHistory] 'POSItemTypes',@Id
		-- end of audit trail	

		UPDATE POSItemTypes SET
		Name = @Name,
		IsActive = @IsActive,
		IsUpload=0
		WHERE Code = @Code AND PropertyId=@PropertyId

		-- audit trail				
		SET @Remark = 'POS item types '+@Code+', '+@Name+' updated.';
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'POSItemTypes',@Id,@UserId,'U',@Remark
		-- end of audit trail	
	END     
END

GO

