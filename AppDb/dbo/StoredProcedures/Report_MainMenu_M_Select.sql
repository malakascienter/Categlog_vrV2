
Create PROCEDURE [dbo].[Report_MainMenu_M_Select]  
	@Category VARCHAR(max),
	@PropertyId INT 
AS  
BEGIN  
	SELECT	MM.Id, MM.ItemCode, MM.FullName AS LongName, C.[Description] AS CategoryName,  
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.Price ELSE  
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewPrice  
			END END AS SellingPrice,   
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.DelivaryPrice ELSE  
			CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewDelivaryPrice  
			END END AS DelivaryPrice,   
			MM.TaxType, MM.ButtonColour AS ButtonColor,  
			MM.Category AS CategoryCode, MM.ApperOnInv AS ShortName,  MM.KitchenDisplayName AS KDSName,   
			--MM.ItemType AS ItemTypeCode, MM.MenuType AS KDSCategory, MM.ProcessTime AS PrepareTime, MM.ButtonColour AS ButtonColor, MM.PackingCharge AS PackagingCharge,  
			MM.costprice AS CostPrice, MM.EFFECTdATE AS EffectFrom, MM.IsModifier, MM.IsInstruction,MM.ActionTemplateID, MM.Active AS IsActive , MM.IsCombo AS IsComboMeal 
			,MM.DefaultActionID,MM.isHighlight,MM.HighlightColour,MM.Credits,MM.PreviousMenuCode,MM.PrinterCode,MM.ProcessTime,MM.discountNotApplicable AS 'DiscountNotApplicable' , MM.IsMainPage,MM.ItemCategory ,MM.IsOpenItem,MM.IsHalfItem,MM.ExecutivePrice
			
	FROM	MainMenu MM  
	INNER	JOIN Category C ON C.Code = MM.Category  AND C.PropertyId=MM.PropertyId
	WHERE	MM.PropertyId=@PropertyId AND C.CatgId  IN (SELECT * FROM STRING_SPLIT(@Category,','))
	ORDER BY MM.ItemCode ASC  
END

GO

