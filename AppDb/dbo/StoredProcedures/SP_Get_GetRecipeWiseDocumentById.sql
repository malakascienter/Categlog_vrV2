
CREATE PROCEDURE [dbo].[SP_Get_GetRecipeWiseDocumentById] 
	@RecipeCode   	VARCHAR(50),
	@PropertyId     INT
AS
BEGIN 
	SELECT * 
	FROM [RecipeWiseDocument] WHERE RecipeCode =@RecipeCode  AND IsActive = 1
END

GO

