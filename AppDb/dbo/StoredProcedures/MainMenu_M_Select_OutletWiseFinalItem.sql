
CREATE  PROCEDURE [dbo].[MainMenu_M_Select_OutletWiseFinalItem]  
	@PropertyId INT,
	@Outlet VARCHAR(5)
AS  
BEGIN  
	
	DECLARE @DefaultPriceTypeId INT 
	SELECT @DefaultPriceTypeId = DefaultPriceTypeId FROM Location_Ref WHERE PropertyId = @PropertyId AND code = @Outlet

	SELECT	MM.Id, MM.ItemCode, MM.Description AS LongName, C.[Description] AS CategoryName,  
		    ISNULL( (SELECT Price FROM POS_OutletWiseMenuItemPrice O WHERE O.PropertyId = MM.PropertyId AND O.MenuItemCode = MM.ItemCode AND O.OutletCode = @Outlet AND PriceTypeID = @DefaultPriceTypeId    ),0) AS SellingPrice,
			MM.TaxType,/*Tax.Description AS 'TaxTypeName',*/ MM.ButtonColour AS ButtonColor,  
			MM.Category AS CategoryCode, MM.ItemCode, MM.[Description] AS ItemName, MM.ApperOnInv AS ShortName, MM.Description AS LongName, MM.KitchenDisplayName AS KDSName,   
			MM.ItemType AS ItemTypeCode, MM.MenuType AS KDSCategory, MM.ProcessTime AS PrepareTime, MM.ButtonColour AS ButtonColor, MM.PackingCharge AS PackagingCharge,  
			MM.costprice AS CostPrice, MM.EFFECTdATE AS EffectFrom, MM.IsModifier, MM.IsInstruction,MM.ActionTemplateID, MM.Active AS IsActive , MM.IsCombo AS IsComboMeal 
			,MM.DefaultActionID,MM.isHighlight,MM.HighlightColour,MM.Credits,MM.PreviousMenuCode,MM.PrinterCode,MM.ProcessTime,MM.discountNotApplicable AS 'DiscountNotApplicable' , MM.IsMainPage,MM.ItemCategory ,MM.IsOpenItem,MM.IsHalfItem,MM.ExecutivePrice,
			(
				SELECT		PS.Code AS 'PrinterCode' 
				FROM		ItemWisePrinters AS IP 
				INNER JOIN	printersetup as ps ON ps.Code=IP.PrinterCode 
				WHERE		MainMenuCode=MM.ItemCode AND IP.PropertyId=@PropertyId 
				FOR JSON Auto
			)AS PrinterCodelstJson,
			CASE WHEN MM.IsUpload = 1 THEN 'Sycn'  
			ELSE 'Not Sync' END AS IsUploadStr
	FROM	MainMenu MM  
	INNER	JOIN Category C ON C.Code = MM.Category  AND C.PropertyId=MM.PropertyId
	INNER JOIN POS_OutletWiseMenuItems OMM ON MM.ItemCode = OMM.MenuCode AND MM.PropertyId = OMM.PropertyId
	WHERE	MM.PropertyId=@PropertyId AND OMM.OutletCode = @Outlet --AND IsFinalProduct = 1
	ORDER BY MM.ItemCode ASC  
END

GO

