
create FUNCTION  [dbo].[FN_GetLastGRNAvgPriceAtDate](@LocationId INT, @StockItemId INT,@Date DATE)

RETURNS DECIMAL(18,6)
AS
BEGIN
 DECLARE @LastGRNAvgPrice  DECIMAL(18,6) 

 SELECT TOP(1)@LastGRNAvgPrice =NewAveragePrice 
 FROM StockTransactionDetails SD
 INNER JOIN StockTransactionHeaders SH 
 ON SD.StockTransactionHeaderID =SH.Id
 WHERE SH.LocationID = CASE WHEN  @LocationId  =-999 THEN SH.LocationID ELSE @LocationId END
 AND SH.TransactionType = 'GR' AND SD.StockItemID = @StockItemId AND SH.TransactionDate <= @Date and UnitPrice <> 0
 ORDER BY SH.TransactionDate DESC ,SD.CreatedDate DESC  ,SD.Id DESC


 RETURN @LastGRNAvgPrice;

END

GO

