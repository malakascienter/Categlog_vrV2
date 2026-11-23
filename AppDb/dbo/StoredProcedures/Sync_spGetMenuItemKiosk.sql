CREATE PROCEDURE [dbo].[Sync_spGetMenuItemKiosk]
@PropertyId INT,
@MenuItem VARCHAR(6)
AS
SET NOCOUNT ON

SELECT	ItemCode, ISNULL(IsShowInKiosk,0) AS IsShowInKiosk, ISNULL(KioskCatId,0) AS KioskCatId, ISNULL(IsKioskMainPage,0) AS IsKioskMainPage,
		ISNULL(KioskItemTypeId,0) AS KioskItemTypeId
FROM	MainMenu
WHERE	PropertyId = @PropertyId AND ItemCode = @MenuItem

GO

