
CREATE FUNCTION  [dbo].[FN_GetSellingPrice](@StockItemID INT = 1, @LocationId INT = 1 , @PropertyID INT = 1) 
RETURNs decimal(18,6)
AS
begin
	DECLARE @SellingPrice AS DECIMAL(18,6)

	SELECT @SellingPrice = ISNULL(SellingPrice,0)
	FROM StockItemDetails
	WHERE StockItemHeaderID = @StockItemID
	AND LocationID = @LocationId
	AND PropertyID  = @PropertyID

	

	RETURN isnull(@SellingPrice,0)


	


end

GO

