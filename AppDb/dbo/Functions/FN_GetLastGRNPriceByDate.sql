CREATE FUNCTION [dbo].[FN_GetLastGRNPriceByDate](@LocationId INT, @StockItemId INT,@ToDate DATE)

RETURNS DECIMAL(18,6)
AS
BEGIN
 DECLARE @LastGRNPrice  DECIMAL(18,6); 

 SELECT TOP(1) @LastGRNPrice =UnitPrice 
 FROM StockTransactionDetails SD
 INNER JOIN StockTransactionHeaders SH 
 ON SD.StockTransactionHeaderID =SH.Id
 WHERE SH.LocationID = CASE WHEN @LocationID  = -999 THEN SH.LocationID  ELSE @LocationID END 
 AND SH.TransactionType = 'GR' AND SD.StockItemID = @StockItemId
 AND TransactionDate <= @ToDate
 ORDER BY SH.TransactionDate DESC
 
 RETURN ISNULL(@LastGRNPrice,0);

END

GO

