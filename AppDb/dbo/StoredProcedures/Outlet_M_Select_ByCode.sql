
CREATE PROCEDURE [dbo].[Outlet_M_Select_ByCode] 
@Code VARCHAR(3),
@PropertyId INT
AS
BEGIN

	
	SET NOCOUNT ON;  
	
SELECT code AS Code ,OutletServer AS IPAddress ,description AS Description ,Active,OutletDatabase, UberEatStoresURL,UberEatclient_id,UberEatclient_secret,UberEatAggregatorType,UberEat_StoreId,UberEat_ChannelCode,PropertyId--,PickMe_XAPIKEY,PickMe_ChannelCode,IsPickMeEnabled
from Location_Ref
WHERE code = @Code AND PropertyId=@PropertyId 




	 
END

GO

