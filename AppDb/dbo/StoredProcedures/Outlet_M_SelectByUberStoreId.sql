
CREATE PROCEDURE [dbo].[Outlet_M_SelectByUberStoreId] 
@StoreId VARCHAR(500)
AS
BEGIN

SET NOCOUNT ON;   


IF EXISTS( SELECT 1 FROM Location_Ref WHERE UberEat_StoreId = @StoreId)
BEGIN

 	SELECT code AS Code ,IPAddress AS IPAddress,OutletDatabase,IPAddressALT ,description AS Description ,Active,PropertyId, UberEatStoresURL,UberEatclient_id,UberEatclient_secret,UberEatAggregatorType,UberEat_StoreId,UberEat_ChannelCode from  
	Location_Ref
	WHERE UberEat_StoreId = @StoreId

END
ELSE
BEGIN

 	SELECT Id as BrandWiseOutletMappingId, Code AS Code ,IPAddress AS IPAddress,OutletDatabase,IPAddressALT ,Description AS Description ,Active,PropertyId, UberEatStoresURL,UberEatclient_id,UberEatclient_secret,UberEatAggregatorType,UberEat_StoreId,UberEat_ChannelCode from  
	BrandWiseOutletMapping
	WHERE UberEat_StoreId = @StoreId

END


	
END

GO

