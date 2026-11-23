
CREATE PROCEDURE [dbo].[SelectReorderLevelRechedItems] (@Type int=0)
AS

IF @Type= 0
BEGIN

	select TOP 50 H.StockItemCode, H.Name,L.Name, QuantityInHand, ReOrderQuantity  
	from StockItemHeaders H
	INNER JOIN StockItemDetails D ON D.StockItemHeaderID = H.ID
	INNER JOIN Locations L ON L.Id = D.LocationID 
	WHERE ReOrderLevel > d.QuantityInHand and D.IsActive= 1 and ReOrderLevel >0
END
ELSE 
BEGIN
	select  H.StockItemCode, H.Name,L.Name, QuantityInHand, ReOrderQuantity  
	from StockItemHeaders H
	INNER JOIN StockItemDetails D ON D.StockItemHeaderID = H.ID
	INNER JOIN Locations L ON L.Id = D.LocationID 
	WHERE ReOrderLevel > d.QuantityInHand and D.IsActive= 1 and ReOrderLevel >0

END

GO

