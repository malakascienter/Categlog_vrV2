-- [dbo].[SP_Search_GetLocationWithStockItemHeaders] 1,1,4168
CREATE PROCEDURE [dbo].[SP_Search_GetLocationWithStockItemHeaders]
(
	@value INT,
	@propertyId int,
	@UserId INT =0
)
	AS 
	DECLARE  @DecimalPlace int

	SELECT @DecimalPlace = DecimalPlaces
	FROM Companies
	WHERE CompanyID = @propertyId
	BEGIN

	
		SELECT        dbo.Locations.Name AS LocationName, dbo.StockItemDetails.LocationID, dbo.StockItemDetails.PropertyID, dbo.StockItemDetails.StockItemHeaderID,ROUND(dbo.StockItemDetails.QuantityInHand,@DecimalPlace) AS QuantityInHand,dbo.StockItemDetails.AveragePrice,dbo.StockItemDetails.SellingPrice, dbo.StockItemDetails.IsActive,dbo.StockItemDetails.ReOrderLevel,dbo.StockItemDetails.ReOrderQuantity,dbo.StockItemDetails.MinimumQuantity,dbo.StockItemDetails.MaximumQuantity,dbo.StockItemDetails.MasterUnitID,U.Name AS UnitName,
		-- 02.04.2024
		dbo.StockItemDetails.ItemAge,
		--
		CASE WHEN dbo.CheckForTransaction (dbo.StockItemDetails.StockItemHeaderID,dbo.StockItemDetails.LocationID)= 1 THEN 0 ELSE 1 END IsUnitEdit
                        
FROM            dbo.StockItemDetails INNER JOIN
                         dbo.Locations ON dbo.StockItemDetails.LocationID = dbo.Locations.Id
						 INNER JOIN dbo.Units U ON u.id=dbo.StockItemDetails.MasterUnitID
						 INNER JOIN UserWise_Location UL ON UL.LocationID =  dbo.StockItemDetails.LocationID 
WHERE        (dbo.StockItemDetails.StockItemHeaderID = @value)
AND UL.UserID = @UserId
ORDER BY dbo.Locations.Name
	END

GO

