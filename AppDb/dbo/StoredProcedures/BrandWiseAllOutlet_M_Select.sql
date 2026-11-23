-- =============================================
-- Author:		Chiraj
-- Create date: 2017-07-24
-- Description:	Select active Outlet
-- =============================================
--[dbo].[Outlet_M_Select]  1,1
CREATE PROCEDURE [dbo].[BrandWiseAllOutlet_M_Select] 
@PropertyId INT
AS
BEGIN

SET NOCOUNT ON;  

DECLARE @IsEnableBrandWiseMenu BIT
SELECT TOP(1) @IsEnableBrandWiseMenu = IsEnableBrandWiseMenu FROM Companies WHERE CompanyID = 	@PropertyId

DECLARE @IsRestaurant BIT = 0
SELECT @IsRestaurant = IsRestaurant  FROM Companies WHERE CompanyID = @PropertyId



IF( @IsEnableBrandWiseMenu = 0 )
BEGIN

	IF( @IsRestaurant = 1 )
	BEGIN
		SELECT code AS Code ,IPAddress AS IPAddress ,description AS Description ,Active,PropertyId, UberEatStoresURL,UberEatclient_id,UberEatclient_secret,UberEatAggregatorType,CurrentDate, CONVERT(varchar,CurrentDate,103) AS CurrentDateStr,UberEat_StoreId,
		OutletDatabase,OutletServer,OutletServerPassword,OutletServerUsername
		from  Location_Ref
		WHERE
		PropertyId=@PropertyId AND Active = 1

	
 

	END
	ELSE
	BEGIN
		SELECT L.code AS Code ,C.POSDataBaseServerName AS IPAddress,C.POSDataBaseServerName AS  OutletServer,L.description AS Description ,L.Active, C.POSDataBaseName AS OutletDatabase,C.CompanyID AS PropertyId, L.UberEatStoresURL,L.UberEatclient_id,L.UberEatclient_secret,UberEatAggregatorType,C.CurrentDate, CONVERT(varchar,C.CurrentDate,103) AS CurrentDateStr,UberEat_StoreId,
		C.POSDataBaseUsername AS OutletServerUsername,C.POSDataBasePassword AS OutletServerPassword
		from Location_Ref L INNER JOIN Companies C ON L.PropertyId = C.CompanyID
		WHERE
		L.PropertyId=@PropertyId AND Active = 1
 
	END
	 

END
ELSE
BEGIN

	SELECT convert(varchar(max),Id) as Code, IPAddress, Description, Active, PropertyId,UberEatStoresURL, UberEatclient_id, UberEatclient_secret,UberEatAggregatorType, CurrentDate, CurrentDateStr,UberEat_StoreId, OutletDatabase, OutletServer,
    OutletServerPassword, OutletServerUsername,BrandID
	from  BrandWiseOutletMapping
	WHERE PropertyId=@PropertyId AND Active = 1 
	 

END

	
END

GO

