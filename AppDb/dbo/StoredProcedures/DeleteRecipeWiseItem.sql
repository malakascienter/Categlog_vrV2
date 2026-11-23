
--ALTER PROCEDURE [dbo].[DeleteRecipeWiseItem]
--	@RecipeId INT,
--	@ItemId INT
--AS
--BEGIN
--	DELETE FROM Inv_RecipeDetails WHERE RecipeHeaderId = @RecipeId AND StockItemId = @ItemId
--END

--Changed 2026-10-23 (audit log) - log each line before the delete; @UserID added
CREATE PROCEDURE [dbo].[DeleteRecipeWiseItem]
	@RecipeId INT,
	@ItemId INT,
	@UserID INT = 0
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
	BEGIN TRANSACTION

		DECLARE @AuditCompanyID INT = ISNULL((SELECT TOP 1 CompanyId FROM Inv_RecipeHeader WHERE Id = @RecipeId), 0)
		DECLARE @AuditRowID INT

		DECLARE @Lines TABLE (Id INT PRIMARY KEY)
		INSERT INTO @Lines (Id)
		SELECT Id FROM Inv_RecipeDetails WHERE RecipeHeaderId = @RecipeId AND StockItemId = @ItemId

		WHILE EXISTS (SELECT 1 FROM @Lines)
		BEGIN
			SELECT TOP 1 @AuditRowID = Id FROM @Lines ORDER BY Id
			EXEC Inventry_AuditTail_WriteToLog 'Inv_RecipeDetails', @AuditRowID, 'INV', 'RDD', 'D', @UserID, @AuditCompanyID, '', ''
			DELETE FROM Inv_RecipeDetails WHERE Id = @AuditRowID
			DELETE FROM @Lines WHERE Id = @AuditRowID
		END

	COMMIT TRAN
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END
--end 2026-10-23 (audit log)

GO

