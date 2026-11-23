CREATE FUNCTION [dbo].[FN_AllGRNValue](@LocationId INT, @StockItemId INT,@FromDate DATE,@ToDate DATE)

RETURNS DECIMAL(18,6)
AS
BEGIN
 DECLARE @AllGRNVal  DECIMAL(18,6); 

 SELECT @AllGRNVal = SUM(Quantity * UnitPrice) 
 FROM StockTransactionDetails SD
 INNER JOIN StockTransactionHeaders SH 
 ON SD.StockTransactionHeaderID =SH.Id
 WHERE SH.LocationID = @LocationId AND SH.TransactionType = 'GR' AND SD.StockItemID = @StockItemId
 AND TransactionDate BETWEEN @FromDate AND  @ToDate
 
 RETURN @AllGRNVal;

END

GO

