CREATE PROCEDURE [dbo].[SP_SELECTSTOCKITEM] 
@SelectedLocationID int

AS
BEGIN 
  
  select SD.Id,SD.StockItemHeaderID,SH.Name,SD.QuantityInHand from StockItemDetails AS SD inner join StockItemHeaders AS SH ON SD.StockItemHeaderID=SH.Id
  where SD.LocationID= @SelectedLocationID

 END

GO

