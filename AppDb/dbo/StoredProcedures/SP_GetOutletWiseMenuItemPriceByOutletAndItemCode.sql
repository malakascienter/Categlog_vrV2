
-- =============================================  

-- ============================================= 
--[dbo].[MainMenu_M_Select] 1
CREATE  PROCEDURE [dbo].[SP_GetOutletWiseMenuItemPriceByOutletAndItemCode]  --1
	@OutletCode NVARCHAR(20),
	@ItemCode NVARCHAR(20),
	@PropertyId INT 
AS  
BEGIN  

	IF NOT EXISTS( SELECT * FROM [POS_OutletWiseMenuItemPrice] WHERE [MenuItemCode] = @ItemCode AND OutletCode = @OutletCode AND PropertyId = @PropertyId )
	BEGIN

	 SELECT TOP(1) @OutletCode = OutletCode FROM [POS_OutletWiseMenuItemPrice] WHERE [MenuItemCode] = @ItemCode AND PropertyId = @PropertyId

	END


	SELECT o.[OutLetWiseMenuItemID]
      ,TRIM(o.[MenuItemCode]) AS MenuItemCode
      ,o.[OutletCode]
      ,o.[PriceTypeID]
      ,o.[Price]
      ,o.[IsActive]
      ,o.[CreatedUser]
      ,o.[CreatedDate]
      ,o.[ModifiedUser]
      ,o.[ModifiedDate]
	  , C.[Description] AS CategoryName
	  , M.Description AS ItemName
	   , M.Id AS MenuItemId
  FROM [dbo].[POS_OutletWiseMenuItemPrice] o inner join MainMenu m on TRIM(o.[MenuItemCode]) = TRIM(m.ItemCode) AND o.PropertyId = M.PropertyId 
  INNER JOIN	Category C ON M.Category  = C.Code AND M.PropertyId = C.PropertyId 
  WHERE TRIM(O.OutletCode) = TRIM(@OutletCode) AND TRIM(O.[MenuItemCode]) = TRIM(@ItemCode) and o.IsActive = 1 AND M.PropertyId = @PropertyId AND C.PropertyId = @PropertyId
  AND O.PropertyId = @PropertyId
  Group by o.[OutLetWiseMenuItemID],
			o.[MenuItemCode]
		   ,o.[OutletCode]
		   ,o.[PriceTypeID]
		   ,o.[Price]
		   ,o.[IsActive]
		   ,o.[CreatedUser]
			,o.[CreatedDate]
			,o.[ModifiedUser]
			,o.[ModifiedDate]
		   , C.[Description] 
		   , M.Description 
		   , M.Id 

END

GO

