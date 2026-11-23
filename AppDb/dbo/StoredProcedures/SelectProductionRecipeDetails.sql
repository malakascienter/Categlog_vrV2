
-- [dbo].[SelectProductionRecipeDetails] 7

CREATE PROCEDURE [dbo].[SelectProductionRecipeDetails] @RecipeHeaderId INT
AS
BEGIN
	--insert  into SelectProductionRecipeDetailsPara
	--select @RecipeHeaderId 

	SELECT H.RecipeName, H.RecipeCode, SI.StockItemCode, IR.Quantity, U.Name AS Unit, SI.Name AS ItemName, 
			ROUND(DD.AveragePrice / [dbo].[FN_GetUnitConvertionRate](SI.companyid,dd.MasterUnitID,IR.unitID),2) UnitPrice, 
			ROUND(IR.Quantity * DD.AveragePrice / [dbo].[FN_GetUnitConvertionRate](SI.companyid,dd.MasterUnitID,IR.unitID),2) Value 
	FROM Inv_RecipeDetails AS IR
	INNER JOIN Units AS U ON U.Id = IR.UnitId
	INNER JOIN StockItemHeaders AS SI ON SI.Id = IR.StockItemId
	INNER JOIN StockItemDetails DD ON DD.StockItemHeaderID = SI.id and IR.locationid = DD.locationid 
	INNER JOIN Inv_RecipeHeader H ON H.Id = IR.RecipeHeaderId
	WHERE IR.RecipeHeaderId = CASE WHEN @RecipeHeaderId=-999 THEN IR.RecipeHeaderId ELSE @RecipeHeaderId END 

END

GO

