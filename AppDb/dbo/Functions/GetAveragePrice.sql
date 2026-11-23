
CREATE FUNCTION  [dbo].[GetAveragePrice] (@PropertyID int, @LocationID int, @StockItemID int ,@TransactionType char(2), @Quantity money , @unitID int,@UnitPrice int)
returns money
as

begin
declare @currentAveragePrice money,
		@currentQuantityInHand money,
		@MasterUnitID int
		
select @currentAveragePrice = AveragePrice, @currentQuantityInHand= QuantityInHand, @MasterUnitID= MasterUnitID 
from dbo.StockItemDetails
where PropertyID=@PropertyID and LocationID =@LocationID and StockItemID=@StockItemID
if @currentAveragePrice is null 
return 0

if @currentAveragePrice =0 and @UnitPrice=0 
return 0

if @currentQuantityInHand =0 and @Quantity=0 
return 0

if @TransactionType not in ('GR','SR','TI')
return @currentAveragePrice

if @TransactionType in ('SR','DN','IN','TO','AAM','II')
set  @Quantity=@Quantity*-1



return  @masterUnitId

return 	((1.0000*@currentAveragePrice * @currentQuantityInHand)+ (1.0000*@Quantity* @UnitPrice * dbo.INV_GetUnitConvertionRate(@PropertyID,@unitID, @masterUnitId)))/ (@currentQuantityInHand+(1.0000*@Quantity * dbo.INV_GetUnitConvertionRate(@PropertyID,@unitID, @masterUnitId)))
		
end

GO

