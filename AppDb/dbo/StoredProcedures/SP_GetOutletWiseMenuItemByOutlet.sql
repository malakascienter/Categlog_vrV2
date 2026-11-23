
CREATE  PROCEDURE [dbo].[SP_GetOutletWiseMenuItemByOutlet]
	@OutletCode NVARCHAR(20),
	@PriceType POS_MainMenuPriceTypes_UDT READONLY,
	@PropertyId INT
AS  
BEGIN  


	SELECT  
      o.[MenuItemCode]
      ,o.[OutletCode]    
      ,o.[IsActive]     
	  , C.[Description] AS CategoryName
	  , M.Description AS ItemName
	   , M.Id AS MenuItemId
  FROM [dbo].[POS_OutletWiseMenuItemPrice] o inner join MainMenu m on o.[MenuItemCode] = m.ItemCode
  INNER JOIN	Category C ON M.Category  = C.Code
  INNER JOIN @PriceType P ON O.PriceTypeID = P.PriceTypeID
  WHERE OutletCode = @OutletCode and o.IsActive = 1 AND o.PropertyId = @PropertyId AND C.PropertyId = @PropertyId
  Group by o.[MenuItemCode]
		   ,o.[OutletCode]		  
		   ,o.[IsActive]		  
		   , C.[Description] 
		   , M.Description 
		   , M.Id 

END

GO

