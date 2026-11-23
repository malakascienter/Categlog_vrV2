

-- =============================================
-- Author:		Chiraj	
-- Create date: 2019-2-26
-- Description:	Select menu item by Id
-- =============================================
--[dbo].[MainMenu_M_Select_ById] 2494, 2
CREATE  PROCEDURE [dbo].[MainMenu_M_Select_ById]
	@MenuitemId INT,
	@PropertyId INT
AS  
BEGIN  

	DECLARE @IsFiscalEnable BIT,@IsAllowUpdate BIT

	SELECT @IsFiscalEnable = IsFiscalEnable FROM Companies WHERE CompanyID = @PropertyId


	IF( @IsFiscalEnable = 1 )
	BEGIN

		
		IF EXISTS( SELECT * FROM BillTrans BT INNER JOIN MainMenu CMM ON BT.MainMenuCode = CMM.ItemCode AND BT.PropertyId = CMM.PropertyId WHERE BT.PropertyId =@PropertyId AND CMM.PropertyId =  @PropertyId AND CMM.Id = @MenuitemId  )
		BEGIN

			SET @IsAllowUpdate = 0

		END
		ELSE
		BEGIN

			SET @IsAllowUpdate = 1

		END

	END
	ELSE
	BEGIN 
		SET @IsAllowUpdate = 1
	END


	SELECT MM.Id,TRIM( MM.ItemCode) AS ItemCode, MM.FullName AS LongName, C.[Description] AS CategoryName,  
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.Price ELSE  
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewPrice  
	END END AS SellingPrice,   
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.DelivaryPrice ELSE  
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewDelivaryPrice  
	END END AS DelivaryPrice,   
	MM.TaxType,MM.ChargeGroupId,/*Tax.Description AS 'TaxTypeName',*/ MM.ButtonColour AS ButtonColor, MM.Active AS IsActive,
	TRIM(MM.Category) AS CategoryCode, TRIM(MM.ItemCode) AS ItemCode, MM.[Description] AS ItemName, MM.ApperOnInv AS ShortName, MM.FullName AS LongName, MM.KitchenDisplayName AS KDSName,   
	MM.ItemType AS ItemTypeCode, MM.MenuType AS KDSCategory, MM.ProcessTime AS PrepareTime, MM.ButtonColour AS ButtonColor, MM.PackingCharge AS PackagingCharge,  
	MM.costprice AS CostPrice, GETDATE() AS EffectFrom, MM.IsModifier, MM.IsInstruction,MM.ActionTemplateID, MM.Active AS IsActive , MM.IsCombo AS IsComboMeal 
	,MM.DefaultActionID,MM.isHighlight,MM.HighlightColour,MM.Credits,MM.PreviousMenuCode,MM.PrinterCode,MM.ProcessTime,MM.discountNotApplicable AS 'DiscountNotApplicable' , MM.IsMainPage,MM.ItemCategory ,MM.IsOpenItem,MM.Setmenu,MM.IsHalfItem,MM.ExecutivePrice,
	(SELECT PS.Code AS 'PrinterCode' FROM ItemWisePrinters AS IP inner join printersetup as ps ON ps.Code=IP.PrinterCode WHERE TRIM(MainMenuCode)=TRIM(MM.ItemCode) AND IP.PropertyId=@PropertyId FOR JSON Auto)AS PrinterCodelstJson,
	(SELECT Id, Description FROM MainMenu WHERE TRIM(PreviousMenuCode) = TRIM(MM.ItemCode) FOR JSON AUTO) as SubMenuItemsJSON,MM.IsFraction,MiniBarCode,IsFinalProduct,IsEButlerItem,
	IsShowInKiosk,KioskCatId,IsKioskMainPage,ItemChargeHeaderID,FiscalCode,MM.Seq AS SeqNo,MM.[Description],@IsAllowUpdate AS IsAllowUpdate,CostPriceType,StockItemId,
	CASE 
    WHEN mm.StockItemId > 0 THEN 1
    ELSE IsERPItem
	END AS IsERPItem,
	(SELECT OutletCode,MenuCode FROM POS_OutletWiseMenuItems WHERE MenuCode = MM.ItemCode AND PropertyId = MM.PropertyId FOR JSON AUTO) AS  ItemWiseOutletJson,
	(SELECT BarCode,MenuCode FROM POS_ItemsBarCode WHERE MenuCode = MM.ItemCode AND PropertyId = MM.PropertyId FOR JSON AUTO) AS  ItemWiseBarCodeJson,
	MM.IsScanDineItem,MM.InvUnitId,
	ISNULL((select top(1) ProductionLocationId from StockItemHeaders where Id = mm.StockItemId),0) InvProductionLocationId,
	ISNULL((select top(1) DeliveryScheduleId from StockItemHeaders where Id = mm.StockItemId),0) InvDeliveryScheduleId,
	(SELECT OrderTypeCode AS Code FROM POS_MenuItemWiseOrderTypes WHERE MenuItemCode = MM.ItemCode AND PropertyId = MM.PropertyId FOR JSON AUTO) AS  ItemChannelListJson,
	(SELECT OrderTypeId FROM POS_MenuItemWiseSpecialOrderTypes WHERE MenuItemCode = MM.ItemCode AND PropertyId = MM.PropertyId FOR JSON AUTO) AS  ItemSpecialOrderTypeListJson,MM.BrandId,MM.IsSchedule,
	KioskItemTypeId
	FROM MainMenu MM  
	INNER JOIN Category C ON C.Code = MM.Category  AND MM.PropertyId = C.PropertyId
	WHERE MM.Id=@MenuitemId AND MM.PropertyId=@PropertyId
	--INNER JOIN TaxGroup_Ref AS Tax ON Tax.ID=MM.TaxType
	ORDER BY MM.Seq ASC --MM.Id DESC  
END

GO

