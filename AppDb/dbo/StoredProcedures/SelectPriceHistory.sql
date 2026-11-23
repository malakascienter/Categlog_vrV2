--EXEC SelectPriceHistory 1,1
CREATE PROCEDURE [dbo].[SelectPriceHistory] (@locationID INT, @stockItemHeaderID INT)
AS 

	SELECT  ROW_NUMBER() OVER (ORDER BY StockItemHeaderId) No,StockItemHeaderId StockItemHeaderId,LocationId LocationId,NewPrice NewPrice,OldPrice OldPrice,EffectedDate EffectedDate 
	FROM PriceChangeLogs
	WHERE DATEDIFF(DAY,EffectedDate, getdate()) <=90 and LocationId = @locationID and StockItemHeaderId =@stockItemHeaderID	 --90

ORDER BY EffectedDate

GO

