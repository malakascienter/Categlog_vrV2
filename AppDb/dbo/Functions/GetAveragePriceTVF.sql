CREATE   FUNCTION [dbo].[GetAveragePriceTVF]
(
    @date DATE,
    @StockItemID INT,
    @LocationId INT,
    @OpeningBalance BIT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        ISNULL(D.NewAveragePrice, 0) AS AvgPrice
    FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
    INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK) ON D.StockTransactionHeaderID = H.Id
    WHERE D.StockItemID = @StockItemID
      AND H.LocationID = @LocationID
      AND H.TransactionDate < CASE WHEN @OpeningBalance=1 THEN @Date ELSE DATEADD(DAY,1,@date) END
    ORDER BY H.TransactionDate DESC, H.CreatedDate DESC
)

GO

