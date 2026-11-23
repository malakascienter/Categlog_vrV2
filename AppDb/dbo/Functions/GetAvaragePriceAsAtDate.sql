
CREATE FUNCTION  [dbo].[GetAvaragePriceAsAtDate](@date DATE = '2018/4/1' ,@StockItemID INT = 1, @LocationId INT = 1 ,@OpeningBalance bit =0) 
RETURNs decimal(18,6)
AS
begin
	DECLARE @Balance AS DECIMAL(18,6)

	SELECT TOP 1 @Balance= ISNULL(D.NewAveragePrice,0) 
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND H.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	WHERE IH.Id = @StockItemID AND H.LocationID = @LocationID AND H.TransactionDate <  CASE WHEN @OpeningBalance=1 THEN @Date ELSE DATEADD(D,1,@date) END 
	ORDER BY H.TransactionDate DESC,  H.CreatedDate DESC

	RETURN isnull(@Balance,0)


	


end

GO

