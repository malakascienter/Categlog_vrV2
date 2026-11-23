
CREATE PROCEDURE [dbo].[Delete_OutletWiseItemBreakDown]
	@MainMenuCode VARCHAR(10),
	@RecipeCode VARCHAR(10),
	@OutletCode VARCHAR(5),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	
	DELETE FROM OutletWiseItemBreakDown WHERE MainMenuCode = @MainMenuCode AND RecipeCode = @RecipeCode AND Outlet = @OutletCode AND PropertyId = @PropertyId


END

GO

