
CREATE PROCEDURE [dbo].[Sync_spGetMenuItemDetails]
@PropertyId INT,
@MenuItem VARCHAR(6)

AS

SELECT	ItemCode, Description, Category, Price, ApperOnInv, Seq, ItemType, PrintCategory, DisplayText, DelivaryPrice,
		Active, Costprice,discountNotApplicable, Setmenu, CONVERT(VARCHAR(50),EffectDate,103) AS EffectDate, NewPrice, NewDelivaryPrice, PreviousMenuCode, IsModifier,
		IsHeading, IsInstruction, ActionTemplateID, Credits, KitchenDisplayName, ProcessTime, IsMainPage, ButtonColour,
		MenuType, DefaultActionID, FullName, IsCombo, IsOpenItem, IsHalfItem, ExecutivePrice, ItemCategory, ISNULL(IsFraction,0) AS IsFraction, ISNULL(MiniBarCode,'') AS MiniBarCode,
		ItemChargeHeaderID, FiscalCode, IsERPItem, IsSchedule, BrandID,
		ISNULL(IsShowInKiosk,0) AS IsShowInKiosk, ISNULL(KioskCatId,0) AS KioskCatId, ISNULL(IsKioskMainPage,0) AS IsKioskMainPage, ISNULL(KioskItemTypeId,0) AS KioskItemTypeId
FROM	MainMenu
WHERE	PropertyId = @PropertyId AND ItemCode = @MenuItem

SELECT	MainMenuCode, MenuCode, AlternateMenuCode, SeqNo, AddRate, ActionButtonID, Qty AS Quantiry
FROM	MenuItemWiseAlternatives
WHERE	MainMenuCode = @MenuItem

SELECT	MainMenuCode, ModifierMenuCode, SeqNo, ActionID, MaxQty
FROM	MenuItemWiseModifier
WHERE	PropertyId = @PropertyId AND MainMenuCode = @MenuItem

SELECT	MainMenuCode, PrinterCode
FROM    ItemWisePrinters
WHERE	PropertyId = @PropertyId AND MainMenuCode = @MenuItem

SELECT	OutletCode, MenuCode
FROM	POS_OutletWiseMenuItems
WHERE	PropertyId = @PropertyId AND MenuCode = @MenuItem

SELECT	MenuItemCode, OutletCode, PriceTypeID, Price, IsActive, NewPrice, CONVERT(VARCHAR(50),EffectiveDate,103) AS EffectiveDate
FROM	POS_OutletWiseMenuItemPrice
WHERE	PropertyId = @PropertyId AND MenuItemCode = @MenuItem

SELECT	SetMenuLevelID, Description
FROM	POS_SetMenuLevels
WHERE	PropertyId = @PropertyId AND SetMenuLevelID IN(SELECT SetMenuLevelID
FROM	POS_SetMenuLevelDetails WHERE	SetMenuItemID = @MenuItem GROUP BY SetMenuLevelID) AND IsActive = 1

SELECT	SetMenuItemID, SetMenuLevelID, SortOrder, LevelQuantity ,IsOptional,MaxQuantity
FROM	POS_SetMenuLevelDetails
WHERE	PropertyId = @PropertyId AND SetMenuItemID = @MenuItem AND IsActive = 1

SELECT	SetMenuItemID, SetMenuLevelID, MenuItemID, AddRate, SortOrder
FROM	POS_SetMenuItemDetails
WHERE	PropertyId = @PropertyId AND SetMenuItemID = @MenuItem

SELECT	MenuCode, BarCode
FROM	POS_ItemsBarCode
WHERE	PropertyId = @PropertyId AND MenuCode = @MenuItem

SELECT	MenuItemCode, OutletCode, PriceTypeID, OldPrice AS Price
FROM	POS_OutletWiseMenuItemPriceChangeLog
WHERE	PropertyId = @PropertyId AND MenuItemCode = @MenuItem AND IsActive = 1

SELECT	MenuCode, CONVERT(VARCHAR(50),FromDate,103) AS FromDate, CONVERT(VARCHAR(50),ToDate,103) AS ToDate,
		CONVERT(VARCHAR(50),FromTime,126) AS FromTime, CONVERT(VARCHAR(50),ToTime,126) AS ToTime
FROM	POS_MenuItemSchedule
WHERE	PropertyId = @PropertyId AND MenuCode = @MenuItem

SELECT	MenuCode, DayName
FROM	POS_MenuItemScheduleDays
WHERE	PropertyId = @PropertyId AND MenuCode = @MenuItem

GO

