--EXEC [dbo].[GetExpireDates] 1006
CREATE  procedure [dbo].[GetExpireDates] @StockItemId INT
AS  
BEGIN 
	  SELECT SUM(BalanceQuantity) Quantity,EXPDate,StockItemID
	  FROM StockItemWiseEXPDateIns 
	  WHERE StockItemID = @StockItemId AND BalanceQuantity > 0
	  GROUP BY EXPDate,StockItemID
END

GO

