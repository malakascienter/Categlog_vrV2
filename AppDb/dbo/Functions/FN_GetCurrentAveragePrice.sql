create FUNCTION [dbo].[FN_GetCurrentAveragePrice]
    (
      @PropertyID INT ,
      @LocationID INT ,
      @StockItemID INT 
    )
RETURNS  DECIMAL(18,6)
AS
    BEGIN
        DECLARE @currentAveragePrice  DECIMAL(18,6) 
		
        SELECT TOP(1) @currentAveragePrice = D.NewAveragePrice
		FROM dbo.StockTransactionDetails AS D
		INNER JOIN  dbo.StockTransactionHeaders AS H ON D.StockTransactionHeaderID = H.Id 
		INNER JOIN dbo.StockItemHeaders AS IH ON D.StockItemID = IH.Id
		INNER JOIN dbo.StockItemDetails AS ID ON IH.Id = ID.StockItemHeaderID AND  ID.LocationID = @LocationID -- AND IH.LocationId = ID.LocationID
		INNER JOIN dbo.Units AS U ON ID.MasterUnitID = U.Id
		WHERE IH.Id = @StockItemId AND H.LocationID = @LocationID and h.PropertyID = @propertyId
		ORDER BY H.TransactionDate DESC ,D.CreatedDate DESC,D.Id DESC

        RETURN 	ISNULL(@currentAveragePrice,0)
    END

GO

