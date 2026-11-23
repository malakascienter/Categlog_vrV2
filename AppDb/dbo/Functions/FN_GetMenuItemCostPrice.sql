CREATE FUNCTION [dbo].[FN_GetMenuItemCostPrice]
(
@ItemCode VARCHAR(20),
@LocationID INT,
@PropertyId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
DECLARE @Cost DECIMAL(18,6);

		
SELECT
@Cost = SUM(StockItemDetails.AveragePrice /[dbo].[FN_GetUnitConvertionRate](@PropertyId, StockItemDetails.MasterUnitID , RecipeDetails.Unit) * RecipeDetails.Qty* ItemBreakDown.Qty )
FROM   RecipeDetails INNER JOIN
RecipeHeader ON RecipeDetails.RecipeCode = RecipeHeader.RecipeCode AND RecipeDetails.PropertyId = RecipeHeader.PropertyId
INNER JOIN StockItemHeaders ON RecipeDetails.StockItemCode = StockItemHeaders.Id AND RecipeDetails.PropertyId  = StockItemHeaders.CompanyId
INNER JOIN StockItemDetails  ON --RecipeDetails.Loc = StockItemDetails.LocationID AND 
StockItemHeaders.Id = StockItemDetails.StockItemHeaderID
INNER JOIN Units ON RecipeDetails.Unit = Units.id
INNER JOIN ItemBreakDown  ON  ItemBreakDown.RecipeCode = RecipeHeader.RecipeCode AND ItemBreakDown.PropertyId = RecipeHeader.PropertyId
INNER JOIN MainMenu ON MainMenu.ItemCode = ItemBreakDown.MainMenuCode AND MainMenu.PropertyId = ItemBreakDown.PropertyId
WHERE RecipeDetails.PropertyId = @PropertyId AND RecipeHeader.PropertyId = @PropertyId AND StockItemHeaders.CompanyId = @PropertyId
AND ItemBreakDown.PropertyId = @PropertyId AND MainMenu.PropertyId = @PropertyId and StockItemDetails.LocationID = @LocationID AND MainMenu.ItemCode = @ItemCode



IF( ISNULL(@Cost,0) = 0 )
BEGIN

 SELECT @Cost = SD.AveragePrice 
 FROM MainMenu MM 
 INNER JOIN StockItemHeaders SH ON MM.StockItemId = SH.Id AND MM.PropertyId = SH.CompanyId
 INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
 WHERE SD.LocationID = @LocationID AND SH.CompanyId = @PropertyId AND MM.PropertyId = @PropertyId AND MM.ItemCode = @ItemCode

END


RETURN ISNULL(@Cost,0)

END

GO

