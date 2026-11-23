CREATE FUNCTION [dbo].[FN_GetProductionRecipeCostPrice]
(
@RecipeCode VARCHAR(20),
@LocationID INT,
@PropertyId INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
DECLARE @Cost DECIMAL(18,6);


SELECT @Cost = SUM( (1*rd.Quantity*1*[dbo].[FN_GetUnitConvertionRate](1,rh.UnitId,rh.UnitId)) * ([dbo].[FN_GetAvgPriceInStockItemDetail](@LocationID,rd.StockItemId) * [dbo].[FN_GetUnitConvertionRate](@PropertyID,rd.UnitId,id.MasterUnitID) ) )
FROM Inv_RecipeDetails rd WITH(NOLOCK)
INNER JOIN Inv_RecipeHeader rh WITH(NOLOCK) ON rd.RecipeHeaderId = rh.Id
INNER JOIN StockItemDetails id WITH(NOLOCK) ON id.StockItemHeaderID = rd.StockItemId
WHERE rh.RecipeCode = @RecipeCode AND ID.LocationID = @LocationID AND rh.CompanyId = @PropertyId 

RETURN ISNULL(@Cost,0)

END

GO

