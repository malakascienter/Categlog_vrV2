
CREATE PROCEDURE [dbo].[SP_GetStockBalance] 
    @Locationid INT ,
    @Propertyid INT,
	@StockItemHeaderID INT 
    WITH RECOMPILE
AS
    BEGIN
		 SELECT QuantityInHand 
		 FROM StockItemDetails
		 WHERE StockItemHeaderID = @StockItemHeaderID AND LocationID = @Locationid AND PropertyID = @Propertyid
    END

GO

