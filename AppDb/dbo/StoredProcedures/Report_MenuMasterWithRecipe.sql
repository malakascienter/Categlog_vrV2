--[Report_MenuMasterWithRecipe] 1
CREATE PROCEDURE [dbo].[Report_MenuMasterWithRecipe]
	 @PropertyId INT

AS
BEGIN
	
	SET NOCOUNT ON;
	
	
SELECT MainMenu.ItemCode,MainMenu.FullName, RecipeHeader.Description, StockItemHeaders.StockItemCode, StockItemHeaders.Name, Units.Name AS Unit, RecipeDetails.Qty ,RecipeHeader.RecipeCode,
StockItemDetails.AveragePrice,MainMenu.Price,ItemBreakDown.Qty AS RecipeQty
FROM   RecipeDetails INNER JOIN
       RecipeHeader ON RecipeDetails.RecipeCode = RecipeHeader.RecipeCode AND RecipeDetails.PropertyId = RecipeHeader.PropertyId
	   INNER JOIN StockItemHeaders ON RecipeDetails.StockItemCode = StockItemHeaders.Id AND RecipeDetails.PropertyId  = StockItemHeaders.CompanyId
	   INNER JOIN StockItemDetails  ON RecipeDetails.Loc = StockItemDetails.LocationID AND StockItemHeaders.Id = StockItemDetails.StockItemHeaderID
	   INNER JOIN Units ON RecipeDetails.Unit = Units.id
	   INNER JOIN ItemBreakDown  ON  ItemBreakDown.RecipeCode = RecipeHeader.RecipeCode AND ItemBreakDown.PropertyId = RecipeHeader.PropertyId
	   INNER JOIN MainMenu ON MainMenu.ItemCode = ItemBreakDown.MainMenuCode AND MainMenu.PropertyId = ItemBreakDown.PropertyId
	   WHERE RecipeDetails.PropertyId = @PropertyId AND RecipeHeader.PropertyId = @PropertyId AND StockItemHeaders.CompanyId = @PropertyId
	   AND ItemBreakDown.PropertyId = @PropertyId AND MainMenu.PropertyId = @PropertyId




END

GO

