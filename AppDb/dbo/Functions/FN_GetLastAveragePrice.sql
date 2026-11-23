CREATE FUNCTION [dbo].[FN_GetLastAveragePrice]
    ( 
      @LocationID INT ,
      @StockItemID INT  
    )
RETURNS  DECIMAL(18,6)
AS
    BEGIN
        DECLARE @LastAvgPrice  DECIMAL(18,6);

		SELECT TOP(1) @LastAvgPrice = D.NewAveragePrice 
		FROM StockTransactionHeaders H
		INNER JOIN StockTransactionDetails D On D.StockTransactionHeaderID = H.Id
		WHERE D.StockItemID = @StockItemID AND H.LocationId = @LocationID
		ORDER BY H.TransactionDate DESC,d.ID DESC

		RETURN ISNULL(@LastAvgPrice,0)
    END

GO

