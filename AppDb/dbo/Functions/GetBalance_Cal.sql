
CREATE FUNCTION  [dbo].[GetBalance_Cal](@date DATE = '2018/4/1' ,@StockItemID INT = 1, @LocationId INT = 1 ,@OpeningBalance bit =0, @byValue bit =0) 
RETURNs DECIMAL(18,6) 
AS
begin
	DECLARE @Balance AS DECIMAL(18,6)

	SELECT top (1) @Balance= ISNULL(D.NewQuantity * CASE WHEN @byValue=1 THEN D.NewAveragePrice ELSE  1 END ,0) 
	FROM dbo.StockTransactionDetails AS D
	INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
	INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
	INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationId -- AND IH.LocationId = ID.LocationID
	INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
	WHERE IH.Id = @StockItemID AND H.LocationID = @LocationID AND H.TransactionDate <  @Date
	ORDER BY H.TransactionDate DESC,H.CreatedDate DESC  ,D.Id DESC

	RETURN isnull(@Balance,0)


end

GO

