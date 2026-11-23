

CREATE  PROCEDURE [dbo].[SP_MainMenuViewByItemCode_M_Select] 
	@ItemCode nvarchar(20),
	@PropertyId INT
AS  
BEGIN  
	SELECT		MM.Id
				, MM.ItemCode
				, MM.FullName AS LongName
				, C.[Description] AS CategoryName
				, MM.Price As SellingPriceString
				, MM.EFFECTdATE
				, CASE WHEN CONVERT(DATE, MM.EFFECTdATE) <= CONVERT(DATE, GETDATE()) THEN MM.NewPrice ELSE CASE WHEN CONVERT(DATE, MM.EFFECTdATE) > CONVERT(DATE, GETDATE()) THEN MM.Price END END AS SellingPrice   
				, CASE WHEN CONVERT(DATE, MM.EFFECTdATE) <= CONVERT(DATE, GETDATE()) THEN MM.NewDelivaryPrice ELSE CASE WHEN CONVERT(DATE, MM.EFFECTdATE) > CONVERT(DATE, GETDATE()) THEN MM.DelivaryPrice END END AS DelivaryPrice
				, MM.ButtonColour AS ButtonColor
				, TaxType
				, MM.Category AS CategoryCode
				, MM.FullName AS ItemName
				, MM.ApperOnInv AS ShortName
				, MM.KitchenDisplayName AS KDSName
				, MM.ItemType AS ItemTypeCode
				, MM.MenuType AS KDSCategory
				, MM.ProcessTime AS PrepareTime
				, MM.ButtonColour AS ButtonColor
				, MM.PackingCharge AS PackagingCharge
				, MM.costprice AS CostPrice
				, MM.EFFECTdATE AS EffectFrom
				, MM.IsModifier
				, MM.IsInstruction
				, MM.ActionTemplateID
				, MM.Active AS IsActive
				, MM.IsCombo AS IsComboMeal 
				, MM.DefaultActionID
				, MM.Credits
				, MM.PreviousMenuCode
				, MM.PrinterCode
				, MM.ProcessTime
				, MM.discountNotApplicable AS 'DiscountNotApplicable' 
				, MM.IsMainPage
				, MM.ItemCategory 
				, MM.IsOpenItem 
				, MM.IsHalfItem
				, MM.ExecutivePrice
				, '[]' AS  PrinterCodelstJson
	FROM		MainMenu MM  
	INNER JOIN	Category C ON C.Code = MM.Category   and c.PropertyId = mm.PropertyId 
	WHERE MM.ItemCode = @ItemCode and mm.PropertyId  =@PropertyId and c.PropertyId = @PropertyId
	ORDER BY	MM.Id DESC  
END

GO

