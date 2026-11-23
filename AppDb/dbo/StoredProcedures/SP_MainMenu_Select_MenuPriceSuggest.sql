
CREATE PROCEDURE [dbo].[SP_MainMenu_Select_MenuPriceSuggest]
	@MenuCode VARCHAR(20),
	@Outlet VARCHAR(5),
	@LocationId INT,
	@PropertyId INT,
	@Type VARCHAR(5)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DefaultPriceType INT 

	SELECT @DefaultPriceType = DefaultPriceTypeId 
	FROM Location_Ref 
	WHERE Code = @Outlet AND PropertyId = @PropertyId

	
IF( @Type = 'M' )
BEGIN

	SELECT  MM.ItemCode AS MenuCode,
			MM.Description AS  MenuName,
			PT.PriceTypeName AS PriceTypeName,
			PT.PriceTypeId AS PriceTypeId,
			ISNULL(P.Price,0) AS Price,
			[dbo].[FN_GetMenuItemCostPrice](@MenuCode,@LocationId,@PropertyId) AS Cost
	FROM MainMenu MM INNER JOIN POS_OutletWiseMenuItemPrice P ON MM.ItemCode = P.MenuItemCode AND MM.PropertyId = P.PropertyId
	INNER JOIN POS_MainMenuPriceTypes PT ON P.PriceTypeID = PT.PriceTypeID
	WHERE MM.ItemCode = @MenuCode AND MM.PropertyId = @PropertyId AND P.OutletCode = @Outlet AND P.PropertyId = @PropertyId AND P.PriceTypeID = @DefaultPriceType 

END
ELSE IF( @Type = 'R' )
BEGIN

	SELECT  MM.RecipeCode AS MenuCode,
			MM.Description AS  MenuName,
			'Default' AS PriceTypeName,
			0 AS PriceTypeId,
			0 AS Price,
			[dbo].[FN_GetMenuRecipeCostPrice](@MenuCode,@LocationId,@PropertyId) AS Cost
	FROM RecipeHeader MM 
	WHERE MM.RecipeCode = @MenuCode AND MM.PropertyId = @PropertyId 

END
ELSE IF( @Type = 'P' )
BEGIN

		SELECT  MM.RecipeCode AS MenuCode,
			MM.RecipeName AS  MenuName,
			'Default' AS PriceTypeName,
			0 AS PriceTypeId,
			0 AS Price,
			[dbo].[FN_GetProductionRecipeCostPrice](@MenuCode,@LocationId,@PropertyId) AS Cost
	FROM Inv_RecipeHeader MM 
	WHERE MM.RecipeCode = @MenuCode AND MM.CompanyId = @PropertyId 

END
   
END

GO

