 -- [dbo].[SP_SelectQuantityInHand2] 1,1,3415,'RT'



 --go
CREATE Procedure [dbo].[SP_SelectQuantityInHand2](@propertyId int,@locationID int, @stockItemID int, @RequestType Char = 'RT')
AS
DECLARE @DecimalPlace int,@SellingPrice DECIMAL(18,6)

--Added by Isuru 2025-03-27 for viewing selling price for franchise outlets
--All outlets selling price equal
SELECT @SellingPrice = ISNULL(SellingPrice,0)
FROM StockItemDetails
WHERE StockItemHeaderID = @stockItemID
AND LocationID = @locationID
--end


SELECT @DecimalPlace = DecimalPlaces
FROM Companies
WHERE CompanyID = @propertyId
--SELECT @propertyId,@locationID,@stockItemID '25555'
select ROUND(dbo.[FN_GetStockInHand_Reatils](@propertyId,@locationID,@stockItemID),@DecimalPlace) AS QuantityInHand,
ISNULL( dbo.FN_GetMasterUnitID(@propertyId,@locationID ,@stockItemID),0) AS MasterUnitId,
ISNULL(dbo.FN_GetAveragePrice(@PropertyID, @LocationID, @stockItemID, @RequestType, 0,

ISNULL( dbo.FN_GetMasterUnitID(@propertyId,@locationID ,@stockItemID),0), 0),0) UnitPrice ,@SellingPrice SellingPrice

GO

