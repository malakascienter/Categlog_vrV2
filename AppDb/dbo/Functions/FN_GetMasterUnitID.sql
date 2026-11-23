

CREATE FUNCTION  [dbo].[FN_GetMasterUnitID]
(@propertyId int, @LocationID int , @StockItemId int )
returns int
begin

declare @MasterUnitID int 

select @MasterUnitID= MasterUnitID from dbo.StockItemDetails
where LocationID =@locationID and StockItemHeaderID=@StockItemId
return @MasterUnitID
end

GO

