
CREATE PROCEDURE [dbo].[Update_ItemBreakDown]
	@MainMenuCode VARCHAR(10),
	@RecipeCode VARCHAR(10),
	@Qty MONEY,
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	
	UPDATE  ItemBreakDown
	SET Qty = @Qty
	WHERE MainMenuCode = @MainMenuCode AND RecipeCode = @RecipeCode AND PropertyId = @PropertyId


END

GO

