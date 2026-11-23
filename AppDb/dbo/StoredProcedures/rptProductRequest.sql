
-- rptProductRequest '',''
CREATE PROCEDURE [dbo].[rptProductRequest]
	@FromDate VARCHAR(20) = '2020-01-01',
	@ToDate VARCHAR(20)  = '3000-01-01'
AS
BEGIN
	IF @FromDate IS NULL OR @FromDate = ''
	BEGIN
		SET @FromDate = '2020-01-01'
		SET @ToDate = '3000-01-01'
	END

	SELECT h.Name,max(s.QuantityInHand) InHandQty,
	SUM(cd.ApprovedQTY* i.Quantity * rd.Quantity * [dbo].[FN_GetUnitConvertionRate](1, rh.UnitId, i.UnitId)) AS Qty,
	MAX(s.QuantityInHand) - SUM(cd.ApprovedQTY* i.Quantity * rd.Quantity * [dbo].[FN_GetUnitConvertionRate](1, rh.UnitId, i.UnitId)) 'BLQty',

	SUM(dbo.FN_GetLastAveragePrice(rd.LocationId, rd.StockItemId)) *
	ABS((MAX(s.QuantityInHand) - SUM(cd.ApprovedQTY* i.Quantity * rd.Quantity * [dbo].[FN_GetUnitConvertionRate](1, rh.UnitId, i.UnitId)))) AS Price

	FROM StockItemHeaders h
	INNER JOIN StockItemDetails s ON s.StockItemHeaderID = h.Id
	INNER JOIN Inv_RecipeDetails rd ON rd.StockItemId = s.StockItemHeaderID
	INNER JOIN Inv_ItemWiseRecipes i ON i.RecipeId = rd.RecipeHeaderId
	INNER JOIN Inv_RecipeHeader rh ON rh.Id = i.RecipeId
	INNER JOIN CommiRequestDetails cd ON cd.StockItemID = i.StockItemId
	INNER JOIN CommiRequestHeader ch ON ch.ID = cd.HeaderID AND s.LocationID= ch.ProductionLocationID
	WHERE cd.RequestedDate BETWEEN @FromDate AND @ToDate
	GROUP BY
	h.Name
	HAVING max(s.QuantityInHand) - SUM(cd.ApprovedQTY* i.Quantity * rd.Quantity * [dbo].[FN_GetUnitConvertionRate](1, rh.UnitId, i.UnitId))
	< 0
END

GO

