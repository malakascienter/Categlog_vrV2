
CREATE PROCEDURE [dbo].[Update_OutletWiseItemBreakDown]
	@MainMenuCode VARCHAR(10),
	@RecipeCode VARCHAR(10),
	@OutletCode VARCHAR(5),
	@Qty DECIMAL(18,2),
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;
	
	UPDATE  OutletWiseItemBreakDown
	SET Qty = @Qty
	WHERE MainMenuCode = @MainMenuCode AND RecipeCode = @RecipeCode  AND Outlet = @OutletCode AND PropertyId = @PropertyId


END

GO

