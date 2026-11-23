
CREATE PROCEDURE ProductionRecipes_M_Select
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

   SELECT Id AS Id,RecipeCode AS RecipeCode,RecipeName AS Description 
   FROM Inv_RecipeHeader 
   WHERE CompanyId = @PropertyId
END

GO

