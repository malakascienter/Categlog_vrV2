
CREATE FUNCTION  [dbo].[GetStockInHand](@propertyId int, @LocationID int , @StockItemId int)
returns money
begin

declare @QuantityInHand int 

select @QuantityInHand= QuantityInHand from dbo.StockItemDetails
where LocationID =@locationID and StockItemId=@StockItemId

return isnull(@QuantityInHand,0)
end

GO

