



CREATE PROCEDURE [dbo].[Sync_spGetMenuList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	ItemCode AS MenuItem
		FROM	MainMenu
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  Code AS MenuItem
		FROM    Sync_MasterDataTransferStatus 
		WHERE	DataType = 'MainMenu' AND PropertyId = @PropertyId AND Outlet = @OutletCode
	END

GO

