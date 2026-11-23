
CREATE PROCEDURE [dbo].[Report_MainMenu_PriceTypeWise_M_Select]  
	@Category VARCHAR(max),
	@Outlet    VARCHAR(4),
	@PropertyId INT 
AS  
BEGIN  

  SELECT  
  M.Id, M.ItemCode
  ,M.FullName AS LongName
  ,C.[Description] AS CategoryName
  ,M.Category AS CategoryCode
  ,M.ApperOnInv AS ShortName
  ,M.KitchenDisplayName AS KDSName
  ,L.description AS Outlet
  ,P.PriceTypeName
  ,ISNULL(o.[Price],0.00) AS [Price]
  ,M.EFFECTdATE,
  IT.Name as mealtype
  ,CASE WHEN M.Active = 1 THEN 'Active' ELSE 'InActive' END AS Status  
  FROM [dbo].[POS_OutletWiseMenuItemPrice] o inner join MainMenu m on o.[MenuItemCode] = m.ItemCode
  INNER JOIN Location_Ref L ON O.[OutletCode] = L.code
  INNER JOIN	Category C ON M.Category  = C.Code
  INNER JOIN ItemCategory it ON m.ItemCategory = IT.Id
  INNER JOIN POS_MainMenuPriceTypes P ON O.PriceTypeID = P.PriceTypeID
  WHERE	M.PropertyId=@PropertyId AND C.CatgId  IN (SELECT * FROM STRING_SPLIT(@Category,','))
  AND O.OutletCode = @Outlet 


END

GO

