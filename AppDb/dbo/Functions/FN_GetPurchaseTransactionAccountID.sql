
CREATE FUNCTION  [dbo].[FN_GetPurchaseTransactionAccountID](@StockItemId bigint, @locationId int)
returns bigint
begin

	
	return isnull((select PurchaseAccountID from dbo.StockItemDetails
	where StockItemHeaderID =@StockItemId and LocationID =@locationId),0)

end

GO

