
CREATE PROCEDURE [dbo].[SP_StockViewer]
	@ItemId int,
	@LocationId int,
	@Function int
AS
BEGIN

if(@Function = 1)
begin	
	select sih.Id ,sih.Name,sd.QuantityInHand,L.Name AS LocationName,[dbo].[FN_GetLastGRNPrice](@LocationId,@ItemId) as LastGRNPrice 
	from StockItemHeaders as SIH 
	inner join StockItemDetails as SD on SIH.id = sd.StockItemId
	inner join Locations as L on L.Id = sd.LocationID
	where sd.LocationID = @LocationId and SIH.Id = @ItemId
end
else
begin
	select sih.Id ,sih.Name,sd.QuantityInHand , L.Name AS LocationName, 
	CASE WHEN [dbo].[FN_GetLastGRNPrice](sd.LocationID,@ItemId)  IS NULL THEN 0 ELSE [dbo].[FN_GetLastGRNPrice](sd.LocationID,@ItemId) END AS LastGRNPrice
	from StockItemHeaders as SIH 
	inner join StockItemDetails as SD on SIH.id = sd.StockItemId
	inner join Locations as L on L.Id = sd.LocationID
	where SIH.Id = @ItemId
end

END

GO

