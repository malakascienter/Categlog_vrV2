-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[POS_MenuItemBreakdown_DependableItem_Select] (
    @ItemICode NVARCHAR(50),
	@PropertyId INT)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 --  SELECT		MM.Id
	--			, MM.ItemCode
	--			, MM.FullName AS LongName
	--			, C.[Description] AS CategoryName
	--			, MM.Price As SellingPriceString
	--			, MM.EFFECTdATE
	--			, CASE WHEN CONVERT(DATE, MM.EFFECTdATE) <= CONVERT(DATE, GETDATE()) THEN MM.NewPrice ELSE CASE WHEN CONVERT(DATE, MM.EFFECTdATE) > CONVERT(DATE, GETDATE()) THEN MM.Price END END AS SellingPrice   
	--			, CASE WHEN CONVERT(DATE, MM.EFFECTdATE) <= CONVERT(DATE, GETDATE()) THEN MM.NewDelivaryPrice ELSE CASE WHEN CONVERT(DATE, MM.EFFECTdATE) > CONVERT(DATE, GETDATE()) THEN MM.DelivaryPrice END END AS DelivaryPrice
	--			, MM.ButtonColour AS ButtonColor
	--			, TaxType
	--			, MM.Category AS CategoryCode
	--			, MM.FullName AS ItemName
	--			, MM.ApperOnInv AS ShortName
	--			, MM.KitchenDisplayName AS KDSName
	--			, MM.ItemType AS ItemTypeCode
	--			, MM.MenuType AS KDSCategory
	--			, MM.ProcessTime AS PrepareTime
	--			, MM.ButtonColour AS ButtonColor
	--			, MM.PackingCharge AS PackagingCharge
	--			, MM.costprice AS CostPrice
	--			, MM.EFFECTdATE AS EffectFrom
	--			, MM.IsModifier
	--			, MM.IsInstruction
	--			, MM.ActionTemplateID
	--			, MM.Active AS IsActive
	--			, MM.IsCombo AS IsComboMeal 
	--			, MM.DefaultActionID
	--			, MM.Credits
	--			, MM.PreviousMenuCode
	--			, MM.PrinterCode
	--			, MM.ProcessTime
	--			, MM.discountNotApplicable AS 'DiscountNotApplicable' 
	--			, MM.IsMainPage
	--			, MM.ItemCategory 
	--			, MM.IsOpenItem 
	--			, MM.IsHalfItem
	--			, MM.ExecutivePrice
	--			, '[]' AS  PrinterCodelstJson
	--FROM		MainMenu MM INNER JOIN	Category C ON C.Code = MM.Category  
 --WHERE MM.ItemCode IN (
 
 --SELECT SU.SetMenuItemID FROM POS_SetMenuLevelDetails SU
 --  WHERE SU.SetMenuLevelID IN 
 --  (SELECT S.DependLevelId FROM POS_SetMenuLevelDetails S
 --  WHERE S.SetMenuItemID = @ItemICode and s.IsdependLevel = 1)
 --  GROUP BY su.leveldetailid, SU.SetMenuItemID,SU.SetMenuLevelID,SU.SortOrder,su.LevelQuantity,
 --  su.isdependlevel,su.isoptional,su.dependlevelid,su.isactive)



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
	FROM		MainMenu MM INNER JOIN	Category C ON  MM.Category  = C.Code and mm.PropertyId = c.PropertyId
 WHERE MM.Category in (SELECT M.Category FROM MainMenu M WHERE M.ItemCode = @ItemICode)  and mm.PropertyId = @PropertyId and c.PropertyId = @PropertyId


END

GO

