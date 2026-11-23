-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[SP_ReplaceRecipeItem]
	@ItemListJson VARCHAR(MAX),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

    
	SELECT *  INTO #tempReplaceRecipeItem
	FROM OPENJSON(@ItemListJson)
	WITH
	(
		RecipeCode           NVARCHAR(15)		'$.RecipeCode',
		UnitId               INT				'$.UnitId',
		Qty                  MONEY			    '$.Qty',
		StockItemId          INT			    '$.StockItemId',
		LocationId           INT			    '$.LocationId',
		ReplaceStockItemId   INT	            '$.ReplaceStockItemId'
	)



	UPDATE R
	SET R.StockItemCode = T.ReplaceStockItemId,
		R.Loc = T.LocationId,
		R.Qty = T.Qty,
		R.Unit = T.UnitId
	FROM RecipeDetails R INNER JOIN #tempReplaceRecipeItem T ON R.RecipeCode = T.RecipeCode AND R.StockItemCode = T.StockItemId
	WHERE R.PropertyId = @PropertyId



END

GO

