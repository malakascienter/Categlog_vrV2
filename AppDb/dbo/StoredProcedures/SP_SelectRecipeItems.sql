-- [dbo].[SP_SelectRecipeItems] 1,4261,1,1

CREATE PROCEDURE [dbo].[SP_SelectRecipeItems]( @LocationId INT,@ItemId INT, @Qty DECIMAL(18,6), @CompanyId INT)
AS
BEGIN
-----------------------------------------------------------------------------
BEGIN TRY
	
	DECLARE @IsRecipeLocationMaintain BIT
	SELECT @IsRecipeLocationMaintain = ISNULL(IsRecipeLocationMaintain,1)
	FROM Companies
	WHERE CompanyID = @CompanyId

	IF(@IsRecipeLocationMaintain = 1)
	BEGIN
		SELECT D.StockItemId, U.Name AS Unit,U.Id AS UnitId,D.Quantity * @Qty AS Qty, SH.Name AS ItemName, sd.QuantityInHand * dbo.FN_GetUnitConvertionRate( PropertyID, sd.MasterUnitID, d.UnitId)	 QuantityInHand
		--,[dbo].[FN_GetLastAveragePrice](@LocationId,D.StockItemId) AveragePrice
		,[dbo].[FN_GetLastAveragePrice](@LocationId,D.StockItemId) / dbo.FN_GetUnitConvertionRate( PropertyID, sd.MasterUnitID, d.UnitId)AveragePrice
		,dbo.FN_GetUnitConvertionRate( PropertyID, sd.MasterUnitID, d.UnitId) ConvertionRate
		FROM Inv_ItemWiseRecipes I
		INNER JOIN Inv_RecipeHeader H ON H.Id = I.RecipeId
		INNER JOIN Inv_RecipeDetails d ON D.RecipeHeaderId = H.Id 
		INNER JOIN Units U ON U.Id = D.UnitId
		INNER JOIN StockItemHeaders SH ON SH.Id = D.StockItemId
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = Sh.Id and I.LocationId = SD.LocationID
		WHERE I.LocationId = CASE WHEN @LocationId = -999 THEN I.LocationId ELSE @LocationId END
		AND I.StockItemId = @ItemId AND I.CompanyId = @CompanyId
	END
	ELSE
	BEGIN
		SELECT D.StockItemId, U.Name AS Unit,U.Id AS UnitId,D.Quantity * @Qty AS Qty, SH.Name AS ItemName, sd.QuantityInHand * dbo.FN_GetUnitConvertionRate( PropertyID, sd.MasterUnitID, d.UnitId)	 QuantityInHand
		--,[dbo].[FN_GetLastAveragePrice](@LocationId,D.StockItemId) AveragePrice
		,[dbo].[FN_GetLastAveragePrice](@LocationId,D.StockItemId) / dbo.FN_GetUnitConvertionRate( PropertyID, sd.MasterUnitID, d.UnitId)AveragePrice
		,dbo.FN_GetUnitConvertionRate( PropertyID, sd.MasterUnitID, d.UnitId) ConvertionRate
		FROM Inv_ItemWiseRecipes I
		INNER JOIN Inv_RecipeHeader H ON H.Id = I.RecipeId
		INNER JOIN Inv_RecipeDetails d ON D.RecipeHeaderId = H.Id 
		INNER JOIN Units U ON U.Id = D.UnitId
		INNER JOIN StockItemHeaders SH ON SH.Id = D.StockItemId
		INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = Sh.Id AND SD.LocationID = @LocationId
		WHERE  I.StockItemId = @ItemId AND I.CompanyId = @CompanyId

	END
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
-----------------------------------------------------------------------------


END

GO

