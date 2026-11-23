
-- =============================================
-- Author:		<Thilini Fernando>
-- Create date: <18-10-2021>
-- Description:	<Description,,>
-- =============================================

--ALTER PROCEDURE [dbo].[SP_SaveRecipeHeaders](@Code NVARCHAR(50)='', @Name NVARCHAR(200)='', @IsActive BIT=0, @type CHAR(1)='I', @Id INT=0, @CompanyId INT=1,@UnitID INT)

CREATE PROCEDURE [dbo].[SP_SaveRecipeHeaders](@Code NVARCHAR(50)='', @Name NVARCHAR(200)='', @IsActive BIT=0, @type CHAR(1)='I', @Id INT=0, @CompanyId INT=1,@UnitID INT, @UserID INT = 0)

AS
BEGIN
	--insert into RecipeHeaderLog values(@Code,@Name,@IsActive,@type,@CompanyId)
	BEGIN TRY
	BEGIN TRANSACTION

-----------------newly added 12.02.2024 ----------------------
			IF(@CompanyId = 0)
		BEGIN
			--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
			--RAISERROR ( @ErrorMsg2, 16, 1 );
			RAISERROR('Error Occured :Company ID Invalid, Please Log In Again',16,1)
			ROLLBACK TRANSACTION
		END
	IF(@UnitID IS NULL)
	BEGIN
		--SET @ErrorMsg2  =  'User ID Invalid, Please Log Again'
		--RAISERROR ( @ErrorMsg2, 16, 1 );
		RAISERROR('Please select unit',16,1)
		ROLLBACK TRANSACTION
	END
-------------------------------------------------------------------

	--added 2026-10-23 - 0 means the caller did not send a user; store NULL, not 0
	DECLARE @AuditUserID INT = NULLIF(@UserID, 0)

	--added 2026-10-23 (audit log)
	DECLARE @AuditLogUserID INT = ISNULL(@UserID, 0)   -- the audit log uses 0 for "not known"
	DECLARE @RecipeHeaderLogID INT
	--end 2026-10-23 (audit log)

	IF(@type = 'I')
	BEGIN
		IF(SELECT COUNT(*) FROM Inv_RecipeHeader WHERE RecipeCode = @Code ) > 0
			RAISERROR('Error Occured : Code already exists',16,1)
		ELSE
		BEGIN
			--INSERT INTO Inv_RecipeHeader VALUES(@Code, @Name,@IsActive, @CompanyId,@UnitID)  -- commented 2026-10-23
			-- 2026-10-23: explicit column list so the audit columns added to Inv_RecipeHeader do not break this insert
			--INSERT INTO Inv_RecipeHeader (RecipeCode, RecipeName, IsActive, CompanyId, UnitId)
			--VALUES (@Code, @Name, @IsActive, @CompanyId, @UnitID)
			INSERT INTO Inv_RecipeHeader (RecipeCode, RecipeName, IsActive, CompanyId, UnitId,
			                              CreatedUserID, CreatedDate, LastModUserID, LastModDate)
			VALUES (@Code, @Name, @IsActive, @CompanyId, @UnitID,
			        @AuditUserID, GETDATE(), @AuditUserID, GETDATE())

			--added 2026-10-23 (audit log) - log the new recipe header
			SET @RecipeHeaderLogID = SCOPE_IDENTITY()
			EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeHeader', @RecipeHeaderLogID, 'INV', 'RCHI', 'I', @AuditLogUserID, @CompanyId, '', ''
			--end 2026-10-23 (audit log)
		END
		--end 2026-10-23
	END
	IF(@type = 'U')
	BEGIN
		IF(SELECT COUNT(*) FROM Inv_RecipeHeader WHERE RecipeCode = @Code AND Id <> @Id ) > 0
			RAISERROR('Error Occured : Code already exists',16,1)
		ELSE
		--Changed 2026-10-23 (audit log) - BEGIN/END added so the log runs with the update
		BEGIN
			--UPDATE Inv_RecipeHeader SET RecipeCode = @Code, RecipeName = @Name,IsActive = @IsActive ,CompanyId = @CompanyId
			--WHERE Id = @Id
			--Changed 2026-10-23 - audit columns filled on update
			UPDATE Inv_RecipeHeader SET RecipeCode = @Code, RecipeName = @Name,IsActive = @IsActive ,CompanyId = @CompanyId,
			       LastModUserID = @AuditUserID, LastModDate = GETDATE()
			WHERE Id = @Id
			--end 2026-10-23

			-- log the change (after the update, so the log holds the new values)
			IF @@ROWCOUNT > 0
				EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeHeader', @Id, 'INV', 'RCHU', 'U', @AuditLogUserID, @CompanyId, '', ''
		END
		--end 2026-10-23 (audit log)
	END
	COMMIT TRAN
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

	END CATCH
END

GO

