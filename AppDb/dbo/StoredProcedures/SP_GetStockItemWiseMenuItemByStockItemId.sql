-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetStockItemWiseMenuItemByStockItemId]
	@StockItemId INT,
	@PropertyId INT,
	@LocationId INT,
	@RecipeCode VARCHAR(10)
AS
BEGIN

	SET NOCOUNT ON;

    SELECT MM.ItemCode,MM.Description AS ItemName,IB.Qty AS RecipeQty
	FROM RecipeDetails RD 
	INNER JOIN RecipeHeader RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId
	INNER JOIN StockItemHeaders SIH ON SIH.Id = RD.StockItemCode
	INNER JOIN StockItemDetails Sd ON SIH.Id = Sd.StockItemHeaderID
	INNER JOIN Units U ON RD.Unit = U.Id
	INNER JOIN ItemBreakDown IB ON IB.RecipeCode = RH.RecipeCode AND IB.PropertyId = RH.PropertyId
	INNER JOIN MainMenu MM ON IB.MainMenuCode = MM.ItemCode AND IB.PropertyId = MM.PropertyId
	WHERE SIH.Id = @StockItemId AND SIH.CompanyId = @PropertyId AND Sd.LocationID = @LocationId AND RH.RecipeCode = @RecipeCode


END

GO

