
CREATE PROCEDURE [dbo].[Delete_ItemBreakDownByMenuCideAndRecipeCode]
	@MainMenuCode VARCHAR(10),
	@RecipeCode VARCHAR(10),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	
	DELETE FROM ItemBreakDown WHERE MainMenuCode = @MainMenuCode AND RecipeCode = @RecipeCode AND PropertyId = @PropertyId


END

GO

