




CREATE PROCEDURE [dbo].[Sync_spGetPropertySettings]
@IsHotelOnly BIT
AS 
SET NOCOUNT ON

IF @IsHotelOnly = 0 
	BEGIN
		SELECT	CompanyID AS PropertyId, OtherBusinessName1 AS PropertyName, PropertyServer AS ServerName, PropertyDatabase AS DatabaseName, IsRestaurant
		FROM	Companies
		WHERE	IsActive = 1 AND PropertyServer != '' 
	END
ELSE
	BEGIN
		SELECT	CompanyID AS PropertyId, OtherBusinessName1 AS PropertyName, PropertyServer AS ServerName, PropertyDatabase AS DatabaseName, IsRestaurant
		FROM	Companies
		WHERE	IsActive = 1 AND PropertyServer != '' AND IsRestaurant = 0 AND CompanyID != 8
	END

GO

