
-- [dbo].[SP_GetLastPurchaseDetails] 3415,1

CREATE PROCEDURE [dbo].[SP_GetLastPurchaseDetails](@stockItemID INT, @LocationId INT)

AS
BEGIN
	
 SELECT TOP (1) UnitPrice AS Price, S.Name AS SupplierName,sh.TransactionDate
 FROM StockTransactionDetails SD
 INNER JOIN StockTransactionHeaders SH 
 ON SD.StockTransactionHeaderID =SH.Id
 INNER JOIN Suppliers S
 ON S.Id = SH.SupplierID
 WHERE SH.LocationID = @LocationId AND SH.TransactionType = 'GR' AND SD.StockItemID = @StockItemId
 ORDER BY SH.Id DESC
END

GO

