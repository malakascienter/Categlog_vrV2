
CREATE  PROCEDURE [dbo].[SP_GetStockBalanceForDate] 
(
	@date DATE = '2018/4/1' ,@StockItemID INT = 1, @LocationId INT = 1 ,@OpeningBalance bit =0, @byValue bit =0
)
AS 

SELECT [dbo].[GetBalance](@date,@StockItemID,@LocationId,@OpeningBalance, @byValue)

GO

