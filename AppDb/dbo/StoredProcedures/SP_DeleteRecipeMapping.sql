
-- =============================================
-- Author:      Tharuka Sachintha
-- Create date: 2026-07-07
-- Description: Removes a single recipe mapped to a production item
--            
-- EXEC [dbo].[SP_DeleteRecipeMapping] @LocationId = 15, @ItemId = 1019, @RecipeId = 3, @CompanyId = 1, @UserID = 4168
-- =============================================
create PROCEDURE [dbo].[SP_DeleteRecipeMapping]
    @LocationId INT,
    @ItemId INT,
    @RecipeId INT,
    @CompanyId INT,
    @UserID INT = 0          -- added 2026-10-23 (audit log)
AS
BEGIN
    SET NOCOUNT ON;

    --DELETE FROM Inv_ItemWiseRecipes
    --WHERE LocationId = @LocationId
    --  AND StockItemId = @ItemId
    --  AND RecipeId = @RecipeId
    --  AND CompanyId = @CompanyId;

    --Changed 2026-10-23 (audit log) - log each mapping before it is deleted
    BEGIN TRY
    BEGIN TRANSACTION

        DECLARE @AuditRowID INT

        DECLARE @Mappings TABLE (Id INT PRIMARY KEY)
        INSERT INTO @Mappings (Id)
        SELECT Id
        FROM Inv_ItemWiseRecipes
        WHERE LocationId = @LocationId
          AND StockItemId = @ItemId
          AND RecipeId = @RecipeId
          AND CompanyId = @CompanyId;

        WHILE EXISTS (SELECT 1 FROM @Mappings)
        BEGIN
            SELECT TOP 1 @AuditRowID = Id FROM @Mappings ORDER BY Id
            EXEC Inventry_AuditTail_WriteToLog 'Inv_ItemWiseRecipes', @AuditRowID, 'INV', 'IWRD', 'D', @UserID, @CompanyId, '', ''
            DELETE FROM Inv_ItemWiseRecipes WHERE Id = @AuditRowID
            DELETE FROM @Mappings WHERE Id = @AuditRowID
        END

    COMMIT TRAN
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
    --end 2026-10-23 (audit log)
END

GO

