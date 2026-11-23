/*
select * from Inv_RecipeHeader
select * from Inv_RecipeDetails
select * from Inv_ItemWiseRecipes
select * from StockItemHeaders
select * from StockItemDetails
*/
-- SelectItemWiseRecipes 4 ,196
create PROCEDURE SelectItemWiseRecipes
	@LocationId INT,
	@StockItemId INT
AS
BEGIN
	SELECT rd.Id,h.Name,rd.Quantity,u.Name Unit,i.UnitId
	FROM Inv_ItemWiseRecipes i
	INNER JOIN Inv_RecipeDetails rd ON rd.RecipeHeaderId = i.RecipeId
	INNER JOIN StockItemHeaders h ON h.Id = rd.StockItemId
	INNER JOIN Units u ON u.Id = rd.UnitId
	WHERE i.LocationId = @LocationId AND i.StockItemId = @StockItemId
END

GO

