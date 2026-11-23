-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-09
-- Description:	Get Location Details

-- [dbo].[SP_GetallLocations_New] -999,4168,'TR',1

-- =============================================
CREATE PROCEDURE [dbo].[SP_GetallLocations_New] 
@ID INT,
@UserID INT,
@Mode CHAR(2),
@PropertyID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsAutoProduction BIT

	SELECT @IsAutoProduction = IsAutoProduction FROM Companies WHERE CompanyID = @PropertyID

	IF(@Mode='CR')
	BEGIN
		IF(@IsAutoProduction =1)
		BEGIN
			SELECT        * 
			FROM           Locations
			WHERE     Locations.companyid  = @Propertyid 
			AND IsActive = 1  --Loading All Locations

		END
		ELSE
		BEGIN
			SELECT        * 
			FROM           Locations
			WHERE     Locations.companyid  = @Propertyid 
			AND IsActive = 1 AND IsProductionLocation=1  --Loading  Production Location

		END
	END

	IF(@Mode='TR')
	BEGIN
		IF(@IsAutoProduction =1)
		BEGIN
			SELECT        * 
			FROM           Locations
			WHERE     Locations.companyid  = @Propertyid 
			AND IsActive = 1  --Loading All Locations

		END
		ELSE
		BEGIN
			SELECT        * 
			FROM           Locations
			WHERE     Locations.companyid  = @Propertyid 
			AND IsActive = 1 --AND ISNULL(IsProductionLocation,0) = 0  --Loading  Production false Location

		END
	END

   
END

GO

