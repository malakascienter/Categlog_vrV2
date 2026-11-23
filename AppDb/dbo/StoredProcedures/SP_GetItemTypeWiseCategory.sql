
CREATE PROCEDURE [dbo].[SP_GetItemTypeWiseCategory](          
 @ItemTypeId  VARCHAR(MAX),
 @CategoryIds VARCHAR(MAX),
 @PropertyId  INT,
 @AggregatorType  INT,
 @Outlet  VARCHAR(MAX),
 @BrandID  INT

)        
AS        
BEGIN    

    DECLARE @IsEnableBrandWiseMenu BIT
    SELECT TOP(1) @IsEnableBrandWiseMenu = IsEnableBrandWiseMenu FROM Companies WHERE CompanyID = 	@PropertyId

	IF( @IsEnableBrandWiseMenu = 0 )
	BEGIN

	 SET @BrandID = 0

	END
	
	SELECT CC.CatgId AS  id,CC.Code,CC.Description AS Name
	FROM MainMenu MM INNER JOIN Category CC ON MM.Category = CC.Code AND MM.PropertyId = CC.PropertyId
	INNER JOIN POSItemTypes PT ON MM.ItemType = PT.Code AND MM.PropertyId = PT.PropertyId
	INNER JOIN AggregatorWiseMenuItem  AM ON MM.ItemCode = AM.MenuCode AND MM.PropertyId = AM.PropertyId
	WHERE CC.CatgId IN (SELECT * FROM STRING_SPLIT(@CategoryIds,',')) AND PT.Id = @ItemTypeId
	AND MM.PropertyId = @PropertyId AND CC.PropertyId = @PropertyId AND PT.PropertyId = @PropertyId
	AND AM.AggregatorId = @AggregatorType AND AM.Outlet = @Outlet AND MM.PropertyId = @PropertyId AND AM.PropertyId =@PropertyId --AND IsMainPage = 0
	AND AM.BrandID = @BrandID
	GROUP BY CC.CatgId ,CC.Code,CC.Description 

END;

GO

