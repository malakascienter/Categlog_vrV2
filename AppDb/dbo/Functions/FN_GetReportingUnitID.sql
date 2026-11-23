

CREATE FUNCTION  [dbo].[FN_GetReportingUnitID](@propertyId int, @LocationID int , @StockItemId int )
returns int
begin

declare @ReportingUnitID int 

select @ReportingUnitID= ReportingUnitID from StockItemDetails
where LocationID =@locationID and StockItemId=@StockItemId
return @ReportingUnitID
end

GO

