
---  [dbo].[SP_SelectQuantityInHand] 1,1,375
CREATE Procedure [dbo].[SP_SelectQuantityInHand](@propertyId int,@locationID int, @stockItemID int)
as
DECLARE @DecimalPlace int

SELECT @DecimalPlace = DecimalPlaces
FROM Companies
WHERE CompanyID = @propertyId

select  [dbo].[FN_GetStockInHand_Reatils](@propertyId,@locationID,@stockItemID)

GO

