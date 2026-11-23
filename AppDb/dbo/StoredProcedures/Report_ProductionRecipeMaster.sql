
CREATE PROCEDURE [dbo].[Report_ProductionRecipeMaster]
	@PropertyId INT,
	@LocationId INT
AS
BEGIN
	
SET NOCOUNT ON;


	select StockItemId,RecipeId
	into #TempRecipeWiseItem
	from Inv_ItemWiseRecipes
	group by StockItemId,RecipeId
	
	SELECT Locations.Name AS LocationName, Inv_RecipeHeader.RecipeCode,Inv_RecipeHeader.RecipeName,StockItemHeaders.StockItemCode AS RawItemCode,StockItemHeaders.Name AS RawItemName,Inv_RecipeDetails.Quantity AS RawItemQty,Units.Name AS RawItemUnit
	,MSI.StockItemCode AS MainItemCode,MSI.Name AS MainItemName
	FROM   Inv_RecipeDetails INNER JOIN
	Inv_RecipeHeader ON Inv_RecipeDetails.RecipeHeaderId = Inv_RecipeHeader.Id
	INNER JOIN StockItemHeaders ON Inv_RecipeDetails.StockItemId = StockItemHeaders.Id
	INNER JOIN StockItemDetails ON StockItemHeaders.Id = StockItemDetails.StockItemHeaderID AND StockItemHeaders.CompanyId = StockItemDetails.CompanyID AND Inv_RecipeDetails.LocationId = StockItemDetails.LocationID 
	INNER JOIN Locations ON StockItemDetails.LocationID = Locations.Id AND StockItemDetails.CompanyID = Locations.CompanyID and Locations.Id = Inv_RecipeDetails.LocationId
	INNER JOIN Units ON Inv_RecipeDetails.UnitId = Units.id
	INNER JOIN #TempRecipeWiseItem  ON #TempRecipeWiseItem.RecipeId = Inv_RecipeHeader.Id
	INNER JOIN StockItemHeaders MSI ON MSI.Id = #TempRecipeWiseItem.StockItemId
	WHERE Inv_RecipeHeader.CompanyId = @PropertyId 


	drop table #TempRecipeWiseItem


END

GO

