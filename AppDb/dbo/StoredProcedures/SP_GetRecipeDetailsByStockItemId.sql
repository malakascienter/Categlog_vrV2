-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetRecipeDetailsByStockItemId]
	@StockItemId INT,
	@PropertyId INT,
	@LocationId INT
AS
BEGIN

	SET NOCOUNT ON;

    SELECT RH.RecipeCode,RH.Description AS RecipeName,U.Name AS UnitName,RD.Qty ,U.Id AS UnitId,SIH.Name AS ItemName,SIH.Id AS StockItemId,Sd.LocationID  AS LocationId
	FROM RecipeDetails RD INNER JOIN RecipeHeader RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId
	INNER JOIN StockItemHeaders SIH ON SIH.Id = RD.StockItemCode
	INNER JOIN StockItemDetails Sd ON SIH.Id = Sd.StockItemHeaderID
	INNER JOIN Units U ON RD.Unit = U.Id
	WHERE SIH.Id = @StockItemId AND SIH.CompanyId = @PropertyId AND Sd.LocationID = @LocationId


END

GO

