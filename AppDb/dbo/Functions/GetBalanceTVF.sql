CREATE  FUNCTION [dbo].[GetBalanceTVF] 
(
    @date DATE,
    @StockItemID INT,
    @LocationId INT,
    @OpeningBalance BIT,
    @byValue BIT
)
RETURNS TABLE
AS
RETURN
(
    SELECT A.BalanceQty,A.AvgPrice,B.BalanceVal 
	FROM (
			SELECT TOP 1
				ISNULL(D.NewQuantity,0) AS BalanceQty
				,ISNULL(D.NewAveragePrice,0) AS AvgPrice,
				D.StockItemID AS StockItemID,
				H.TransactionDate , H.CreatedDate
			FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
			INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK) ON D.StockTransactionHeaderID = H.Id
			WHERE D.StockItemID = @StockItemID
			  AND H.LocationID = @LocationID
			  AND H.TransactionDate < DATEADD(DAY,1,@date)
			ORDER BY H.TransactionDate DESC, H.CreatedDate DESC

	) A
	INNER JOIN 
	(
		 SELECT TOP 1
			ISNULL(D.NewQuantity * D.NewAveragePrice, 0) AS BalanceVal,
				D.StockItemID AS StockItemID,
				H.TransactionDate , H.CreatedDate
		FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
		INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK) ON D.StockTransactionHeaderID = H.Id
		WHERE D.StockItemID = @StockItemID
		  AND H.LocationID = @LocationID
		  AND H.TransactionDate <= @Date
		ORDER BY H.TransactionDate DESC, H.CreatedDate DESC

	) B ON A.StockItemID = B.StockItemID
)

GO

