-- =============================================
-- Author:		Tharuka sachintha
-- Create date: 2026-10-14
-- Description:	Raw Material Usage / Reverse Traceability Report (RPT_RawMaterialUsageTraceReport)

--  [dbo].[RPT_SP_Production_RawMaterialTrace] 1, -999, '2026-01-01', '2026-12-31', -999

-- =============================================
CREATE   PROCEDURE [dbo].[RPT_SP_Production_RawMaterialTrace]
	@PropertyID	 INT,
	@LocationID	 INT,
	@FromDate	 DATETIME,
	@ToDate		 DATETIME,
	@StockItemID INT = -999		-- raw material
AS
BEGIN

	SET NOCOUNT ON;

	SET @LocationID  = ISNULL(@LocationID, -999);
	SET @StockItemID = ISNULL(@StockItemID, -999);

	SELECT
		C.RawMaterialID,
		RM.StockItemCode		AS RawMaterialCode,
		RM.Name					AS RawMaterial,
		C.TransactionDate,
		PU.DocumentNo			AS ProductionRef,
		FI.StockItemCode		AS FinishedItemCode,
		FI.Name					AS FinishedItem,
		ISNULL(RN.RecipeNames, '-') AS RecipeName,
		ISNULL(L.Name, '-')		AS Location,
		C.ProductionQty,
		ISNULL(PUU.Name, '-')	AS ProductionUOM,
		C.StandardQty,
		C.ActualQty,
		C.VarianceQty,
		ISNULL(U.Name, '-')		AS UOM
	FROM dbo.FN_RPT_ProductionRunConsumption(@PropertyID, @LocationID, @FromDate, @ToDate, -999, @StockItemID, -999) C
	INNER JOIN StockTransactionHeaders PU ON PU.Id = C.ProductionHeaderID
	INNER JOIN StockItemHeaders FI ON FI.Id = C.FinishedItemID
	INNER JOIN StockItemHeaders RM ON RM.Id = C.RawMaterialID
	LEFT JOIN Units PUU ON PUU.Id = C.ProductionUnitID
	LEFT JOIN Units U ON U.Id = C.UnitID
	LEFT JOIN Locations L ON L.Id = C.LocationID
	-- Recipes mapped to the finished item (same location rule as the standard)
	-- that contain this raw material. Blank when it was issued but is no longer
	-- in the recipe.
	OUTER APPLY (
		SELECT STUFF((
			SELECT DISTINCT ', ' + RTRIM(RH.RecipeName)
			FROM Inv_ItemWiseRecipes IR
			INNER JOIN Inv_RecipeHeader RH ON RH.Id = IR.RecipeId
			INNER JOIN Inv_RecipeDetails RD ON RD.RecipeHeaderId = RH.Id
			WHERE IR.StockItemId = C.FinishedItemID
			  AND IR.CompanyId = C.PropertyID
			  AND (C.IsRecipeLocationMaintain = 0 OR IR.LocationId = C.LocationID)
			  AND RD.StockItemId = C.RawMaterialID
			FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 2, '') AS RecipeNames
	) RN
	WHERE C.RawMaterialID IS NOT NULL
	ORDER BY RM.Name, C.TransactionDate, C.ProductionHeaderID;

END

GO

