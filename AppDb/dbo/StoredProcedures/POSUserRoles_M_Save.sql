-- =============================================

-- =============================================
CREATE PROCEDURE [dbo].[POSUserRoles_M_Save]
(
	@Id INT,
	@Name NVARCHAR(100),
	@UserId INT = -1,
	@Operation CHAR(1),
	@IsActive BIT,
	@PropertyId	INT
)

AS
BEGIN
SET NOCOUNT ON;
	IF(@Operation = 'I')
		BEGIN
			INSERT INTO POSUserRoles(Name, IsActive, CreatedUserId, CreatedDateTime, LastUpdatedUserId, LastUpdatedDateTime,IsUpload,PropertyId)
			VALUES(@Name, @IsActive,@UserId, GETDATE(), @UserId, GETDATE(),0,@PropertyId)
			--SET @Id = SCOPE_IDENTITY()

			SET @Id = SCOPE_IDENTITY()
			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POSUserRoles',@Id,'POS','POSURI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

         END
		 ELSE IF(@Operation = 'U')
		 BEGIN
		 IF EXISTS (SELECT 1 FROM POSUserRoles WHERE Id = @Id)
		 BEGIN

			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POSUserRoles',@Id,'POS','POSURU','U',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------

			UPDATE  POSUserRoles
		    SET			
			Name = @Name,
			LastUpdatedDateTime = GETDATE(),
			LastUpdatedUserId = @UserId,
			IsActive = @IsActive,
			IsUpload=0
			WHERE Id = @Id AND PropertyId=@PropertyId
		END
		ELSE
		BEGIN
			RAISERROR('No record exists.',16,1)
		END		
	END
	ELSE
	BEGIN
		RAISERROR('Invalid operation',16,1)
	END


END

GO

