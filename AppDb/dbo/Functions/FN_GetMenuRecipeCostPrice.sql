CREATE FUNCTION [dbo].[FN_GetMenuRecipeCostPrice]
(
@RecipeCode VARCHAR(20),
@LocationID INT,
@PropertyId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
DECLARE @Cost DECIMAL(18,6);

		
SELECT
@Cost = SUM(StockItemDetails.AveragePrice /[dbo].[FN_GetUnitConvertionRate](@PropertyId, StockItemDetails.MasterUnitID , RecipeDetails.Unit) * RecipeDetails.Qty )
FROM   RecipeDetails INNER JOIN
RecipeHeader ON RecipeDetails.RecipeCode = RecipeHeader.RecipeCode AND RecipeDetails.PropertyId = RecipeHeader.PropertyId
INNER JOIN StockItemHeaders ON RecipeDetails.StockItemCode = StockItemHeaders.Id AND RecipeDetails.PropertyId  = StockItemHeaders.CompanyId
INNER JOIN StockItemDetails  ON --RecipeDetails.Loc = StockItemDetails.LocationID AND 
StockItemHeaders.Id = StockItemDetails.StockItemHeaderID
INNER JOIN Units ON RecipeDetails.Unit = Units.id
WHERE RecipeDetails.PropertyId = @PropertyId AND RecipeHeader.PropertyId = @PropertyId AND StockItemHeaders.CompanyId = @PropertyId
AND StockItemDetails.LocationID = @LocationID AND RecipeHeader.RecipeCode = @RecipeCode



RETURN ISNULL(@Cost,0)

END

GO

