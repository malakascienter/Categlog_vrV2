
-- =============================================
-- Author:		Chiraj
-- Create date: 2018-9-5
-- Description: MainMenu_M_Select_For_ComboSetup
-- =============================================
CREATE PROCEDURE [dbo].[MainMenu_M_Select_For_ComboSetup]
@MenuCode VARCHAR(4),
@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT MM.Id, MM.ItemCode, ISNull(MM.FullName,MM.Description) AS LongName, C.[Description] AS CategoryName,
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.Price ELSE
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewPrice
	END END AS SellingPrice, 
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) = CONVERT(VARCHAR(10),GETDATE(),101) OR CONVERT(VARCHAR(10),MM.EFFECTdATE,101) < CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.DelivaryPrice ELSE
	CASE WHEN CONVERT(VARCHAR(10),MM.EFFECTdATE,101) > CONVERT(VARCHAR(10),GETDATE(),101) THEN MM.NewDelivaryPrice
	END END AS DelivaryPrice, 
	MM.TaxType, MM.ButtonColour AS ButtonColor,
	MM.Category AS CategoryCode, MM.ItemCode, MM.[Description] AS ItemName, MM.ApperOnInv AS ShortName, MM.FullName AS LongName, MM.KitchenDisplayName AS KDSName, 
	MM.ItemType AS ItemTypeCode, MM.MenuType AS KDSCategory, MM.ProcessTime AS PrepareTime, MM.ButtonColour AS ButtonColor, MM.PackingCharge AS PackagingCharge,
	MM.costprice AS CostPrice, MM.EFFECTdATE AS EffectFrom, MM.IsModifier, MM.IsInstruction, MM.Active AS IsActive , MM.IsOpenItem,MM.IsHalfItem,MM.ExecutivePrice
	FROM MainMenu MM
	INNER JOIN Category C ON C.Code = MM.Category AND C.PropertyId=MM.PropertyId
	WHERE MM.ItemCode<>@MenuCode AND MM.PropertyId=@PropertyId
	ORDER BY MM.Id DESC
END

GO

