
-- =============================================
-- Author:		Chamathka
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE  PROCEDURE [dbo].[KDSCategory_M_Save]
	@Code		CHAR(3),
	@Name		VARCHAR(50),
	@Active		BIT,
	@UserId		INT,
	@Operation	CHAR(1),
	@PropertyId INT

AS
BEGIN TRY
	DECLARE @Id INT
	DECLARE @Remark VARCHAR(MAX)
	

	IF @Operation ='I'  
	BEGIN 
		IF  EXISTS(SELECT 1  FROM POSKDSCategory WHERE PropertyId=@PropertyId AND (Code = @Code OR Name = @Name))
		BEGIN  
			RAISERROR('KDS Category Name OR Code already exists',16,1)  
		END		
		ELSE
		BEGIN	

			INSERT INTO POSKDSCategory	(Code, Name,Active,PropertyId,IsUpload,CreatedUserId,CreatedDateTime)	
			VALUES (@Code,@Name,@Active,@PropertyId,0,@UserId,GETDATE())				
			SELECT @Id = Id FROM POSKDSCategory WHERE Code=@Code AND PropertyId=@PropertyId
				--audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'POSKDSCategory',@Id
				--end of audit trail

				--audit trail				
			SET @Remark = 'KDS Category '+@Name+' created.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'POSKDSCategory',@Id,@UserId,'I',@Remark
				--end of audit trail		
		END
	END
	ELSE IF @Operation ='U'  
	BEGIN
		IF EXISTS(SELECT 1 FROM POSKDSCategory where  PropertyId=@PropertyId AND Name=@Name AND Code<>@Code)       
		BEGIN  
			RAISERROR('Name already exists',16,1)  
		END  
		ELSE  
		BEGIN
			SELECT @Id = Id FROM POSKDSCategory WHERE Code=@Code AND PropertyId=@PropertyId
			 --audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'POSKDSCategory',@Id
			 --end of audit trail

			UPDATE POSKDSCategory
			SET 
			  Name = @Name,
			Active = @Active,
			PropertyId=@PropertyId,
			UpdatedUserId=@UserId,
			UpdatedDateTime=GETDATE(),
			IsUpload=0
			WHERE Code = @Code AND PropertyId=@PropertyId

			 --audit trail				
			SET @Remark = 'KDS Category '+@Code+', '+@Name+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'POSKDSCategory',@Id,@UserId,'U',@Remark
			 --end of audit trail	
		END
	END
END TRY 
BEGIN CATCH
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

