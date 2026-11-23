-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectLevelDependLevelItemList]
	@MenuItemCode NVARCHAR(10),
	@LevelCode NVARCHAR(10),
	@PropertyId INT
AS
BEGIN
SET NOCOUNT ON;

	SELECT 
	   MM.Id
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
	FROM MainMenu MM  
	INNER JOIN Category C ON C.Code = MM.Category  and mm.PropertyId = c.PropertyId 
	INNER JOIN [POS_SetMenuItemDetails] P ON MM.ItemCode = P.[MenuItemID] and mm.PropertyId = p.Propertyid
	WHERE P.[SetMenuItemID] = @MenuItemCode  AND P.IsActive = 1 and mm.PropertyId = @PropertyId and c.PropertyId = @PropertyId and P.Propertyid = @PropertyId
	AND P.[SetMenuLevelID] IN 
						  (SELECT [DependLevelId]     
						  FROM [dbo].[POS_SetMenuLevelDetails]
						  WHERE [SetMenuItemID] = @MenuItemCode AND  
						  [SetMenuLevelID] = @LevelCode 
						  AND [IsDependLevel] = 1 AND Propertyid =@PropertyId )

END

GO

