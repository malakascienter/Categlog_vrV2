-- =============================================
-- Author:		Chiraj
-- Create date: 2017-07-24
-- Description:	Select active Outlet
-- =============================================
--[dbo].[Outlet_M_Select]  1,1
CREATE PROCEDURE [dbo].[Outlet_M_Select] 
@Active INT = 2,
@PropertyId INT
AS
BEGIN

SET NOCOUNT ON;   
DECLARE @IsRestaurant BIT = 0

SELECT @IsRestaurant = IsRestaurant  FROM Companies WHERE CompanyID = @PropertyId


IF( @IsRestaurant = 1 )
BEGIN
	SELECT code AS Code ,IPAddress AS IPAddress ,description AS Description ,Active,PropertyId, UberEatStoresURL,UberEatclient_id,UberEatclient_secret,UberEatAggregatorType,CurrentDate, CONVERT(varchar,CurrentDate,103) AS CurrentDateStr,UberEat_StoreId,
	OutletDatabase,OutletServer,OutletServerPassword,OutletServerUsername,BadaginiApiKey
	from  Location_Ref
	WHERE
	PropertyId=@PropertyId AND (@Active = 2 OR Active = @Active)

	
 

END
ELSE
BEGIN
	SELECT L.code AS Code ,C.POSDataBaseServerName AS IPAddress,C.POSDataBaseServerName AS  OutletServer,L.description AS Description ,L.Active, C.POSDataBaseName AS OutletDatabase,C.CompanyID AS PropertyId, L.UberEatStoresURL,L.UberEatclient_id,L.UberEatclient_secret,UberEatAggregatorType,C.CurrentDate, CONVERT(varchar,C.CurrentDate,103) AS CurrentDateStr,UberEat_StoreId,
	C.POSDataBaseUsername AS OutletServerUsername,C.POSDataBasePassword AS OutletServerPassword,l.BadaginiApiKey
	from Location_Ref L INNER JOIN Companies C ON L.PropertyId = C.CompanyID
	WHERE
	L.PropertyId=@PropertyId AND (@Active = 2 OR L.Active = @Active)
 
END
	

	
END

GO

