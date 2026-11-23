
CREATE PROCEDURE [dbo].[SP_SelectItemWiseRecipes](@LocationId INT, @ItemId INT, @CompanyId INT)
AS
BEGIN
----------------------------------------------------
BEGIN TRY 
	SELECT RecipeId AS itemId,rh.RecipeName itemName,i.UnitId,u.Name as UnitName,Quantity AS Qty,i.LocationId
	FROM Inv_ItemWiseRecipes i
	INNER JOIN Inv_RecipeHeader rh ON rh.Id = i.RecipeId
	INNER JOIN Units u ON u.Id = i.UnitId 
	WHERE i.LocationId = CASE WHEN @LocationId = -999 THEN i.LocationId ELSE @LocationId END
	AND Stockitemid = @ItemId AND i.CompanyId = @CompanyId
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
----------------------------------------------------


END

GO

