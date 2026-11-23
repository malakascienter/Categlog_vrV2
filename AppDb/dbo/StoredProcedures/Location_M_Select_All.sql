-- =============================================
-- Author:		Banu
-- Create date: 14/02/2019
-- Description:	Select All location including Inventory for userwise outlets
-- =============================================
----EXECUETE Location_M_Select_All 2
CREATE PROCEDURE [dbo].[Location_M_Select_All]
	@Active	INT,
	@PropertyId INT
AS
BEGIN

	SELECT   LO.code
			,LO.description
			,LO.NextNo
			,LO.ID
			,LO.RoomService
			,LO.BevAccCode
			,LO.FoodAccCode
			,LO.TobacooAccCode
			,LO.LiquorAccCode
			,LO.OtherAccCode
			,LO.DeptCode
			,LO.SerChgVal
			,LO.WineAccCode
			,LO.CostBevAccCode
			,LO.CostFoodAccCode
			,LO.CostTobacooAccCode
			,LO.CostLiquorAccCode
			,LO.CostOtherAccCode
			,LO.CostWineAcccode
			,LO.KOTLoc
			,LO.BOTLoc
			,1 AS Active -- Location Active manually change
			,LO.CPU
			,LO.IPAddress
			,LO.Kitchen_Code
			,LO.FGLoc
			,LO.StoreID
			,LO.IPAddressALT
			,LO.ORGID
			,LO.TakeoutSalesAccCode
			,LO.DeliverySalesAccCode
			,LO.DriveThroSalesAccCode
			,LO.DriveInSalesAccCode
			,LO.PartySalesAccCode
			,LO.SalesAccCode
			,LO.location_Add_Code
			,LO.LOB_Code
			,LO.AdvanceAccCode
			,LO.DashboardDisplayOrder
			,LO.PropertyId
			,LO.StockLocationID
			,LO.DepartmentID
			,LO.OutletDatabase
			,LO.IsDefault
			,LO.OutletServer
			,LO.OutletServerUsername
			,LO.OutletServerPassword
			,LO.CurrentDate
			,LO.RefCode
			,LO.RefName
			,LO.StalllCode
			,LO.StallName
			,LO.UberEatStoresURL
			,LO.UberEatclient_id
			,LO.UberEatclient_secret
			,LO.UberEatAggregatorType
			,LO.UberEat_StoreId
			,LO.UberEat_ChannelCode
			,LO.DefaultPriceTypeId
			--,LO.PickMe_ChannelCode
			--,LO.PickMe_XAPIKEY
			--,LO.IsPickMeEnabled
			,LO.IsForeignCurrency
			,LO.IsGLEnabled
			,LO.BaseCurrencyCode
			--,LO.Pickme_StoreId
	FROM Location_Ref LO 
	WHERE PropertyId=@PropertyId AND ( @Active = 2 OR LO.Active = @Active  )

END

GO

