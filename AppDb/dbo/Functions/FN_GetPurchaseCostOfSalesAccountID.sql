
CREATE FUNCTION  [dbo].[FN_GetPurchaseCostOfSalesAccountID](@StockItemId bigint, @locationId int)
returns bigint
begin

	
	return isnull((select CostOfSalesAccountID from dbo.StockItemDetails
	where StockItemHeaderID =@StockItemId and LocationID =@locationId),0)

end

GO

