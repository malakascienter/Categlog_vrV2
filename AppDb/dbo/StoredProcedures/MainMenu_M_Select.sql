
-- =============================================  
-- Author:  Chamathka  
-- Create date:   
-- Description:   
-- ============================================= 
--[dbo].[MainMenu_M_Select] 2
CREATE  PROCEDURE [dbo].[MainMenu_M_Select]  --1
	@PropertyId INT
AS  
BEGIN  
	SELECT	MM.Id, MM.ItemCode, MM.FullName AS LongName, C.[Description] AS CategoryName,  
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.Price ELSE  
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewPrice  
			END END AS SellingPrice,   
			--ISNULL((select TOP(1) Price from POS_OutletWiseMenuItemPrice op inner join Location_Ref L ON OP.OutletCode  = L.code AND OP.PropertyId = L.PropertyId AND L.DefaultPriceTypeId = OP.PriceTypeID   where OP.MenuItemCode = mm.ItemCode and OP.PropertyId = mm.PropertyId and L.IsDefault = 1 ),0) AS SellingPrice,   
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.DelivaryPrice ELSE  
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewDelivaryPrice  
			END END AS DelivaryPrice,   
			MM.TaxType,/*Tax.Description AS 'TaxTypeName',*/ MM.ButtonColour AS ButtonColor,  
			MM.Category AS CategoryCode, MM.ItemCode, MM.[Description] AS ItemName, MM.ApperOnInv AS ShortName, MM.FullName AS LongName, MM.KitchenDisplayName AS KDSName,   
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
	WHERE	MM.PropertyId=@PropertyId
	ORDER BY MM.ItemCode ASC  
END

GO

