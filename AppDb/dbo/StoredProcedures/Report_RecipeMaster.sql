
CREATE PROCEDURE [dbo].[Report_RecipeMaster]
	@PropertyId INT
AS
BEGIN
	
SET NOCOUNT ON;
	
SELECT Locations.Name AS STLocation,RecipeHeader.RecipeCode, RecipeHeader.Description AS RecipeName, StockItemHeaders.StockItemCode, StockItemHeaders.Name, 
Units.Name AS Unit, RecipeDetails.Qty,StockItemDetails.AveragePrice/[dbo].[FN_GetUnitConvertionRate](@PropertyId, StockItemDetails.MasterUnitID , RecipeDetails.Unit) AS Price
FROM   RecipeDetails INNER JOIN
       RecipeHeader ON RecipeDetails.RecipeCode = RecipeHeader.RecipeCode AND  RecipeDetails.PropertyId = RecipeHeader.PropertyId
	   INNER JOIN StockItemHeaders ON RecipeDetails.StockItemCode = StockItemHeaders.Id AND RecipeDetails.PropertyId = StockItemHeaders.CompanyId
	   INNER JOIN StockItemDetails ON StockItemHeaders.Id = StockItemDetails.StockItemHeaderID AND StockItemHeaders.CompanyId = StockItemDetails.CompanyID AND RecipeDetails.Loc = StockItemDetails.LocationID 
	   INNER JOIN Locations ON StockItemDetails.LocationID = Locations.Id AND StockItemDetails.CompanyID = Locations.CompanyID
	   INNER JOIN Units ON RecipeDetails.Unit = Units.id
	   WHERE RecipeDetails.PropertyId = @PropertyId AND RecipeHeader.PropertyId = @PropertyId AND StockItemHeaders.CompanyId = @PropertyId AND StockItemDetails.CompanyID = @PropertyId
--ORDER BY RecipeDetails.RecipeCode
UNION ALL
SELECT '' AS STLocation,RecipeHeader.RecipeCode, RecipeHeader.Description AS RecipeName, '' AS StockItemCode, '' AS Name,'' AS Unit, '' AS Qty,0 AS Price
FROM   RecipeHeader 
WHERE RecipeHeader.PropertyId = @PropertyId AND RecipeHeader.RecipeCode NOT IN (

SELECT RecipeHeader.RecipeCode
FROM   RecipeDetails INNER JOIN
       RecipeHeader ON RecipeDetails.RecipeCode = RecipeHeader.RecipeCode  AND  RecipeDetails.PropertyId = RecipeHeader.PropertyId
	   INNER JOIN StockItemHeaders ON RecipeDetails.StockItemCode = StockItemHeaders.Id AND RecipeDetails.PropertyId = StockItemHeaders.CompanyId
	   INNER JOIN StockItemDetails ON StockItemHeaders.Id = StockItemDetails.StockItemHeaderID AND StockItemHeaders.CompanyId = StockItemDetails.CompanyID AND RecipeDetails.Loc = StockItemDetails.LocationID 
	   INNER JOIN Locations ON StockItemDetails.LocationID = Locations.Id AND StockItemDetails.CompanyID = Locations.CompanyID
	   INNER JOIN Units ON RecipeDetails.Unit = Units.id 
	    WHERE RecipeDetails.PropertyId = @PropertyId AND RecipeHeader.PropertyId = @PropertyId AND StockItemHeaders.CompanyId = @PropertyId AND StockItemDetails.CompanyID = @PropertyId
--ORDER BY RecipeDetails.RecipeCode

)


END

GO

