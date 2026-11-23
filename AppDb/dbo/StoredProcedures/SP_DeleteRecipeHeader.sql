
-- =============================================
-- Author:		<Thhilini Fernando>
-- Create date: <21-10-2021>
-- Description:	<Description,,>
-- =============================================
--ALTER PROCEDURE [dbo].[SP_DeleteRecipeHeader](@Id INT)
CREATE PROCEDURE [dbo].[SP_DeleteRecipeHeader](@Id INT, @UserID INT = 0)   -- @UserID added 2026-10-23 (audit log)
AS
BEGIN
	BEGIN TRY
	BEGIN TRANSACTION
		--added 2026-10-23 (audit log) - log the header before it is deleted
		DECLARE @AuditCompanyID INT
		SELECT @AuditCompanyID = ISNULL(CompanyId, 0) FROM Inv_RecipeHeader WHERE Id = @Id

		IF @AuditCompanyID IS NOT NULL
			EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeHeader', @Id, 'INV', 'RCHD', 'D', @UserID, @AuditCompanyID, '', ''
		--end 2026-10-23 (audit log)

		DELETE FROM Inv_RecipeHeader WHERE Id = @Id
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

