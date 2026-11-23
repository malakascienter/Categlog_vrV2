create PROCEDURE SelectStockItems
AS
BEGIN
	SELECT Id,StockItemCode,Name
	FROM StockItemHeaders
END

GO

