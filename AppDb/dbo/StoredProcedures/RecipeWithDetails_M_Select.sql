-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-13
-- Description:RecipeWithDetails_M_Select
-- =============================================
--[RecipeWithDetails_M_Select] 1
CREATE PROCEDURE [dbo].[RecipeWithDetails_M_Select]
	@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;
	SELECT 
	 LTRIM(RTRIM(RecipeCode)) AS RecipeCode
	,Description
	,Ord_Type
	,LowerVariencePerc
	,HigherVariencePerc 
	,(SELECT rd.* ,sm.Name As ItemName,sm.StockItemCode AS StockItemCodeStr FROM RecipeDetails as rd 
	inner join StockItemHeaders As sm On sm.Id=rd.StockItemCode and sm.LocationId=rd.Loc
	 where rd.RecipeCode=RecipeHeader.RecipeCode AND rd.PropertyId=@PropertyId FOR JSON AUTO )AS RecipeDetailJson,
	 AdditionalCost,
	 IsPercentage
	 FROM RecipeHeader  WHERE PropertyId=@PropertyId order by Id


	

END

GO

