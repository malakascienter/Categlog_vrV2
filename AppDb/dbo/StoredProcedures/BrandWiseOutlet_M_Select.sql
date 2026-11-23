

/* ----------------------------------------------------------------------------
   5. BrandWiseOutlet_M_Select - carry Maalu_StoreId to the Outlet combo.

   Three result sets, all of which must return the column or the Outlet model
   binds it as null on some properties and not others. Body is otherwise
   unchanged from the version left by PickMeItemStatusChange_Migration.sql.

   >>> If this procedure has been altered on the target database since that
       migration, merge by hand rather than running this section blind. <<<
   ---------------------------------------------------------------------------- */
CREATE PROCEDURE [dbo].[BrandWiseOutlet_M_Select]
@BrandId INT ,
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
		OutletDatabase,OutletServer,OutletServerPassword,OutletServerUsername,BadaginiApiKey,PickMe_ApiKey,Maalu_StoreId
		from  Location_Ref
		WHERE
		PropertyId=@PropertyId AND Active = 1

	END
	ELSE
	BEGIN
		SELECT L.code AS Code ,C.POSDataBaseServerName AS IPAddress,C.POSDataBaseServerName AS  OutletServer,L.description AS Description ,L.Active, C.POSDataBaseName AS OutletDatabase,C.CompanyID AS PropertyId, L.UberEatStoresURL,L.UberEatclient_id,L.UberEatclient_secret,UberEatAggregatorType,C.CurrentDate, CONVERT(varchar,C.CurrentDate,103) AS CurrentDateStr,UberEat_StoreId,
		C.POSDataBaseUsername AS OutletServerUsername,C.POSDataBasePassword AS OutletServerPassword,BadaginiApiKey AS BadaginiApiKey,L.PickMe_ApiKey,L.Maalu_StoreId
		from Location_Ref L INNER JOIN Companies C ON L.PropertyId = C.CompanyID
		WHERE
		L.PropertyId=@PropertyId AND Active = 1

	END


END
ELSE
BEGIN

	SELECT Code, IPAddress, Description, Active, PropertyId,UberEatStoresURL, UberEatclient_id, UberEatclient_secret,UberEatAggregatorType, CurrentDate, CurrentDateStr,UberEat_StoreId, OutletDatabase, OutletServer,
    OutletServerPassword, OutletServerUsername,BrandID,BadaginiApiKey,PickMe_ApiKey,Maalu_StoreId
	from  BrandWiseOutletMapping
	WHERE PropertyId=@PropertyId AND Active = 1 AND BrandID = @BrandId


END


END

GO

