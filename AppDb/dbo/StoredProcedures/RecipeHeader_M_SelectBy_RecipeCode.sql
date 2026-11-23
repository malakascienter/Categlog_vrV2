-- =============================================
-- Author:		Chiraj
-- Create date: 2019-2-14
-- Description:	RecipeHeader_M_SelectBy_RecipeCode
-- =============================================
CREATE PROCEDURE [dbo].[RecipeHeader_M_SelectBy_RecipeCode] 
	@RecipeCode VARCHAR(6),
	@PropertyId INT
AS
BEGIN	
	SET NOCOUNT ON;
	SELECT 
	CONVERT(VARCHAR(6),RecipeCode)AS RecipeCode,
	Description,IsBanquetRecipe ,AdditionalCost,IsPercentage
	FROM RecipeHeader WHERE RecipeCode=@RecipeCode AND PropertyId=@PropertyId
END

GO

