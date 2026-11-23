
CREATE FUNCTION  [dbo].[FN_GetLastGRNPrice](@LocationId INT, @StockItemId INT)

RETURNS DECIMAL(18,6)
AS
BEGIN
 DECLARE @LastGRNPrice  DECIMAL(18,6) 

 SELECT TOP(1)@LastGRNPrice =UnitPrice 
 FROM StockTransactionDetails SD
 INNER JOIN StockTransactionHeaders SH 
 ON SD.StockTransactionHeaderID =SH.Id
 WHERE SH.LocationID = CASE WHEN  @LocationId  =-999 THEN SH.LocationID ELSE @LocationId END
 AND SH.TransactionType = 'GR' AND SD.StockItemID = @StockItemId
 ORDER BY SH.TransactionDate DESC ,SD.CreatedDate DESC  ,SD.Id DESC

 RETURN @LastGRNPrice;

END

GO

