
-- [dbo].[SP_SelectRecipeWiseItems] 2018,1
-- [dbo].[SP_SelectRecipeWiseItems] 2022,2604,1

--CREATE PROCEDURE [dbo].[SP_SelectRecipeWiseItems](@Id INT,@LocId INT = 0)
--Changed 2026-10-28 - @ShowAllItems added (optional, so other callers are unaffected)
CREATE PROCEDURE [dbo].[SP_SelectRecipeWiseItems](@Id INT,@LocId INT = 0,@ShowAllItems BIT = 0)
AS
BEGIN
--SD.AveragePrice *
DECLARE @CompanyID INT,@IsRecipeLocationMaintain BIT

SELECT @IsRecipeLocationMaintain = CO.IsRecipeLocationMaintain,@CompanyID = CO.CompanyID
FROM Companies CO
INNER JOIN Inv_RecipeHeader IR ON CO.CompanyID = IR.CompanyId
WHERE IR.Id = @Id

	--added 2026-10-28 - Recipe Wise Items pop-up: keep lines whose item is not set up at @LocId
	-- (LEFT JOIN instead of INNER JOIN), flagged with IsInLocation = 0 and zero cost.
	IF(@ShowAllItems = 1 AND @LocId IS NOT NULL AND @LocId <> -999)
	BEGIN
		SELECT D.Id,
		CASE WHEN SD.StockItemHeaderID IS NULL THEN 0
		     ELSE SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](H.CompanyId, D.UnitId, SD.MasterUnitID) END AS CostPrice,
		D.StockItemId AS ItemId, H.Name AS ItemName ,D.UnitId, U.Name AS UnitName, D.Quantity AS Qty, D.LocationId,L.Name AS Location,
		ISNULL(SD.AveragePrice, 0) AS AveragePrice,
		CASE WHEN SD.StockItemHeaderID IS NULL THEN 0
		     ELSE SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](H.CompanyId, D.UnitId, SD.MasterUnitID) * D.Quantity END AS ItemValue,
		CAST(CASE WHEN SD.StockItemHeaderID IS NULL THEN 0 ELSE 1 END AS BIT) AS IsInLocation
		FROM Inv_RecipeDetails D
		INNER JOIN StockItemHeaders H ON D.StockItemId = H.Id
		LEFT JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID = D.StockItemId
		AND SD.LocationID = @LocId
		INNER JOIN Units U ON U.Id = D.UnitId
		LEFT JOIN Locations L On L.Id = @LocId
		WHERE D.RecipeHeaderId = @Id
		--location-wise recipes: only this location's lines (same as the IsRecipeLocationMaintain = 1 branch below)
		AND (ISNULL(@IsRecipeLocationMaintain, 0) = 0 OR D.LocationId = @LocId)

		RETURN
	END
	--end 2026-10-28


	IF(@LocId IS  NULL) 
	BEGIN
		IF(@IsRecipeLocationMaintain = 1)
		BEGIN
		SELECT D.Id, SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](h.CompanyId, d.UnitId,sd.MasterUnitID) * D.Quantity  As CostPrice, D.StockItemId AS ItemId, H.Name AS ItemName ,D.UnitId, U.Name AS UnitName, D.Quantity AS Qty, D.LocationId,LC.Name AS Location,
		(SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](h.CompanyId, d.UnitId,sd.MasterUnitID) * D.Quantity) * D.Quantity AS ItemValue
		FROM Inv_RecipeDetails D
		INNER JOIN StockItemHeaders H ON D.StockItemId = H.Id
		INNER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID =H.Id
		INNER JOIN Locations LC on LC.Id = SD.LocationID 
		INNER JOIN Units U ON U.Id = D.UnitId
		WHERE D.RecipeHeaderId = @Id AND LC.ID IN (SELECT TOP(1) ID FROM Locations WHERE DefaultLocation=1)
		END
		ELSE
		BEGIN
			SELECT D.Id, 0 As CostPrice, D.StockItemId AS ItemId, H.Name AS ItemName ,D.UnitId, U.Name AS UnitName, D.Quantity AS Qty, D.LocationId,LC.Name AS Location,
			0 * D.Quantity AS ItemValue
			FROM Inv_RecipeDetails D
			INNER JOIN StockItemHeaders H ON D.StockItemId = H.Id
			INNER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID =H.Id
			INNER JOIN Locations LC on LC.Id = SD.LocationID 
			INNER JOIN Units U ON U.Id = D.UnitId
			WHERE D.RecipeHeaderId = @Id AND LC.ID IN (SELECT TOP(1) ID FROM Locations WHERE DefaultLocation=1)
		END
	END
	ELSE
	BEGIN
		IF(@IsRecipeLocationMaintain = 1)
		BEGIN
			SELECT D.Id, SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](h.CompanyId, D.UnitId,sd.MasterUnitID) As CostPrice,
			D.StockItemId AS ItemId, H.Name AS ItemName ,D.UnitId, U.Name AS UnitName, D.Quantity AS Qty, D.LocationId,L.Name AS Location,
			SD.AveragePrice,
			SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](h.CompanyId, D.UnitId,sd.MasterUnitID) *  D.Quantity AS ItemValue
			FROM Inv_RecipeDetails D
			INNER JOIN StockItemHeaders H ON D.StockItemId = H.Id
			INNER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID = D.StockItemId 
			AND SD.LocationID = CASE WHEN @LocId = -999 THEN SD.LocationId ELSE @LocId END
			INNER JOIN Units U ON U.Id = D.UnitId
			LEFT JOIN Locations L On L.Id = @LocId
			WHERE D.RecipeHeaderId = @Id 
			AND D.LocationId = CASE WHEN @LocId = -999 THEN D.LocationId ELSE @LocId END
		END
		ELSE 
		BEGIN
			IF(@LocId  = -999)
			BEGIN

			SELECT TOP (1) @LocId = ID
			FROM Locations
			WHERE CompanyID= @CompanyID
			AND DefaultLocation=1
			END

			SELECT D.Id, SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](h.CompanyId, D.UnitId,sd.MasterUnitID) As CostPrice,
			D.StockItemId AS ItemId, H.Name AS ItemName ,D.UnitId, U.Name AS UnitName, D.Quantity AS Qty, D.LocationId,L.Name AS Location,
			SD.AveragePrice,
			SD.AveragePrice * dbo.[FN_GetUnitConvertionRate](h.CompanyId, D.UnitId,sd.MasterUnitID) * D.Quantity AS ItemValue
			FROM Inv_RecipeDetails D
			INNER JOIN StockItemHeaders H ON D.StockItemId = H.Id
			INNER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID = D.StockItemId 
			AND SD.LocationID = @LocId
			--AND SD.LocationID = CASE WHEN @LocId = -999 THEN SD.LocationId ELSE @LocId END
			INNER JOIN Units U ON U.Id = D.UnitId
			LEFT JOIN Locations L On L.Id = @LocId
			WHERE D.RecipeHeaderId = @Id 
			--AND D.LocationId = CASE WHEN @LocId = -999 THEN D.LocationId ELSE @LocId END
		
		END

	END
END

GO

