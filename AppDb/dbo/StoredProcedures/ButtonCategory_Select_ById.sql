
CREATE PROCEDURE [dbo].[ButtonCategory_Select_ById]
	@MenuitemId INT,
	@PropertyId INT
AS  
BEGIN  
	SELECT MM.Id, MM.ItemCode, MM.Description AS LongName, MM.Category AS CategoryName,  
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.Price ELSE  
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewPrice  
	END END AS SellingPrice,   
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.DelivaryPrice ELSE  
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewDelivaryPrice  
	END END AS DelivaryPrice,   
	MM.TaxType,MM.ChargeGroupId,/*Tax.Description AS 'TaxTypeName',*/ MM.ButtonColour AS ButtonColor, MM.Active AS IsActive,
	MM.Category AS CategoryCode, MM.ItemCode, MM.[Description] AS ItemName, MM.ApperOnInv AS ShortName, MM.FullName AS LongName, MM.KitchenDisplayName AS KDSName,   
	MM.ItemType AS ItemTypeCode, MM.MenuType AS KDSCategory, MM.ProcessTime AS PrepareTime, MM.ButtonColour AS ButtonColor, MM.PackingCharge AS PackagingCharge,  
	MM.costprice AS CostPrice, MM.EFFECTdATE AS EffectFrom, MM.IsModifier, MM.IsInstruction,MM.ActionTemplateID, MM.Active AS IsActive , MM.IsCombo AS IsComboMeal 
	,MM.DefaultActionID,MM.isHighlight,MM.HighlightColour,MM.Credits,MM.PreviousMenuCode,MM.PrinterCode,MM.ProcessTime,MM.discountNotApplicable AS 'DiscountNotApplicable' , MM.IsMainPage,MM.ItemCategory ,MM.IsOpenItem,MM.Setmenu,MM.IsHalfItem,MM.ExecutivePrice,
	(SELECT PS.Code AS 'PrinterCode' FROM ItemWisePrinters AS IP inner join printersetup as ps ON ps.Code=IP.PrinterCode WHERE MainMenuCode=MM.ItemCode AND IP.PropertyId=@PropertyId FOR JSON Auto)AS PrinterCodelstJson,
	(SELECT Id, Description FROM MainMenu WHERE PreviousMenuCode = MM.ItemCode FOR JSON AUTO) as SubMenuItemsJSON,MM.IsFraction,MiniBarCode,Seq as SeqNo
	FROM MainMenu MM  
	WHERE MM.Id=@MenuitemId AND MM.PropertyId=@PropertyId
	--INNER JOIN TaxGroup_Ref AS Tax ON Tax.ID=MM.TaxType
	ORDER BY MM.Id DESC  
END

GO

