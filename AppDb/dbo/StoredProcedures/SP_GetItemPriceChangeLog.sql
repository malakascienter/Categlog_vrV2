
CREATE  PROCEDURE [dbo].[SP_GetItemPriceChangeLog]
	@OutletCode     NVARCHAR(5),
	@MenuCode       NVARCHAR(10),
	@PriceTypeId    INT,
	@PropertyId		INT
AS  
BEGIN  


SELECT TOP(50) o.OutLetWiseMenuItemID
      ,O.[MenuItemCode] AS MenuItemCode
      ,O.[OutletCode] AS OutletCode    
      ,O.[IsActive] AS IsActive   
	  ,O.OldPrice AS Price
	  ,O.CreatedDate AS ChangeDate
  FROM [dbo].POS_OutletWiseMenuItemPriceChangeLog o 
  --INNER JOIN MainMenu m on o.[MenuItemCode] = m.ItemCode
 -- INNER JOIN Category C ON M.Category  = C.Code
  WHERE OutletCode = @OutletCode  AND o.PropertyId = @PropertyId AND o.PriceTypeID = @PriceTypeId AND o.MenuItemCode = @MenuCode
 Order by o.OutLetWiseMenuItemID DESC

END

GO

