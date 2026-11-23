
CREATE FUNCTION  [dbo].[FN_GetStockInHand](@propertyId int, @LocationID int , @StockItemId int)
returns  DECIMAL(18,6) 
begin

declare @QuantityInHand DECIMAL(18,6) 
select @QuantityInHand= QuantityInHand from dbo.StockItemDetails
where LocationID =@locationID and  StockItemHeaderID =@StockItemId

return isnull(@QuantityInHand,0)

end

GO

