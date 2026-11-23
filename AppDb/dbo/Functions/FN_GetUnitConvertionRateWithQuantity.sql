--Created by: Nivesh
--Created Date: 2024-10-10
-- select [dbo].[FN_GetUnitConvertionRateWithQuantity](1,19,2,1)
CREATE FUNCTION  [dbo].[FN_GetUnitConvertionRateWithQuantity](@PropertyId int, @FromUnitId int, @ToUnitId int, @Qty decimal(18,8))
returns DECIMAL(18,8)
begin
declare @Rate DECIMAL(18,8)

if @FromUnitId= @ToUnitId 
	return 1*isnull(@Qty,1)

select @Rate=Value*isnull(@Qty,1) from UnitConversions
where FromUnitId=@FromUnitId and ToUnitID=@ToUnitId and CompanyId = @PropertyId

if @Rate is not null 
	return @Rate


select @Rate=1/Value*isnull(@Qty,1) from UnitConversions
where FromUnitId=@ToUnitId and ToUnitID=@FromUnitId and CompanyId = @PropertyId
if @Rate is not null 
	return @Rate 

return -1

end

GO

