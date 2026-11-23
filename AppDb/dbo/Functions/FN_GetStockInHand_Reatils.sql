
CREATE FUNCTION  [dbo].[FN_GetStockInHand_Reatils](@propertyId int, @LocationID int , @StockItemId int)
returns  DECIMAL(18,6) 
begin

DECLARE @IsRetail BIT
DECLARE @QuantityInHand DECIMAL(18,6) 
DECLARE @SalesQty MONEY
DECLARE @IsRestaurant BIT
DECLARE @CurrentDate DATE
DECLARE @SalesReturnQty MONEY

SELECT @IsRetail = IsRetail,@IsRestaurant = IsRestaurant,@CurrentDate = CurrentDate
FROM Companies
WHERE CompanyID = @propertyId



IF( @IsRestaurant = 1 )
BEGIN

 SELECT @CurrentDate = CurrentDate FROM Locations where id = @LocationID

END



IF( @IsRetail = 1 )
BEGIN

	select @QuantityInHand= QuantityInHand from dbo.StockItemDetails
	where LocationID =@locationID and StockItemId=@StockItemId



	IF EXISTS( SELECT * FROM POS_InvoiceDetail WHERE BusinessDate = @CurrentDate AND ItemID = @StockItemId AND LocationID = @LocationID AND CompanyID = @propertyId )
	BEGIN
		SELECT @SalesQty = SUM(Quantity) FROM POS_InvoiceDetail WHERE BusinessDate = @CurrentDate AND ItemID = @StockItemId AND LocationID = @LocationID AND CompanyID = @propertyId
	END
	ELSE
	BEGIN
		SET @SalesQty = 0
	END

	IF EXISTS( SELECT * FROM POS_SalesReturnDetail WHERE BusinessDate = @CurrentDate AND ItemID = @StockItemId AND LocationID = @LocationID AND CompanyID = @propertyId )
	BEGIN
		SELECT @SalesReturnQty = SUM(Quantity) FROM POS_SalesReturnDetail WHERE BusinessDate = @CurrentDate AND ItemID = @StockItemId AND LocationID = @LocationID AND CompanyID = @propertyId
	END
	ELSE
	BEGIN
		SET @SalesReturnQty = 0
	END

	SET  @QuantityInHand = (isnull(@QuantityInHand,0)-@SalesQty)+ISNULL(@SalesReturnQty,0)
 

END
ELSE
BEGIN

	select @QuantityInHand= QuantityInHand from dbo.StockItemDetails
	where LocationID =@locationID and StockItemHeaderID=@StockItemId

	SET  @QuantityInHand = isnull(@QuantityInHand,0)
 

END

return isnull(@QuantityInHand,0)
end

GO

