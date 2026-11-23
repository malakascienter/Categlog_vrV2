-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-10-14
-- Description:	Shared source for the production consumption reports
				
--  SELECT * FROM [dbo].[FN_RPT_ProductionRunConsumption](1, -999, '2026-01-01', '2026-12-31', -999, -999, -999)


-- =============================================
CREATE   FUNCTION [dbo].[FN_RPT_ProductionRunConsumption]
(
	@PropertyID		 INT,
	@LocationID		 INT,	-- -999 = all locations
	@FromDate		 DATE,
	@ToDate			 DATE,
	@FinishedItemID	 INT,	-- -999 = all finished items
	@RawMaterialID	 INT,	-- -999 = all raw materials
	@ProductionRefID INT	-- PU StockTransactionHeaders.Id, -999 = all runs
)
RETURNS TABLE
AS
RETURN
(
	WITH Runs AS
	(
		SELECT
			PU.Id				AS ProductionHeaderID,
			PU.PropertyID,
			PU.LocationID,
			PU.TransactionDate,
			PD.StockItemID		AS FinishedItemID,
			PD.Quantity			AS ProductionQty,
			PD.TxnUnitID		AS ProductionUnitID,
			-- 'Pr%duction' also matches if the screen's 'Prduction recipe' typo is ever fixed
			CASE WHEN PU.Remarks LIKE 'Pr%duction recipe%' THEN 'Manual'
				 WHEN PU.Remarks LIKE 'AUTO PU%' THEN 'Auto'
				 ELSE 'Plan / Other' END AS ProductionType,
			ISNULL(C.IsRecipeLocationMaintain, 1) AS IsRecipeLocationMaintain
		FROM StockTransactionHeaders PU
		INNER JOIN StockTransactionDetails PD ON PD.StockTransactionHeaderID = PU.Id
		LEFT JOIN Companies C ON C.CompanyID = PU.PropertyID
		WHERE PU.TransactionType = 'PU'
		  AND PU.PropertyID = @PropertyID
		  AND (@LocationID = -999 OR PU.LocationID = @LocationID)
		  AND PU.TransactionDate BETWEEN @FromDate AND @ToDate
		  AND (@FinishedItemID = -999 OR PD.StockItemID = @FinishedItemID)
		  AND (@ProductionRefID = -999 OR PU.Id = @ProductionRefID)
	),
	StdLines AS
	(
		SELECT
			R.ProductionHeaderID,
			RD.StockItemId	AS RawMaterialID,
			TU.UnitID,
			-- NULL for the whole item when any line lacks a unit conversion, rather
			-- than a SUM that silently drops that line.
			CASE WHEN COUNT(*) = COUNT(Q.Qty) THEN SUM(Q.Qty) END AS StandardQty
		FROM Runs R
		INNER JOIN Inv_ItemWiseRecipes IR ON IR.StockItemId = R.FinishedItemID
										 AND IR.CompanyId = R.PropertyID
										 AND (R.IsRecipeLocationMaintain = 0 OR IR.LocationId = R.LocationID)
		INNER JOIN Inv_RecipeHeader RH ON RH.Id = IR.RecipeId
		INNER JOIN Inv_RecipeDetails RD ON RD.RecipeHeaderId = RH.Id
		CROSS APPLY (SELECT ISNULL(dbo.FN_GetMasterUnitID(R.PropertyID, R.LocationID, RD.StockItemId), RD.UnitId) AS UnitID) TU
		CROSS APPLY (SELECT dbo.FN_GetUnitConvertionRate(R.PropertyID, RD.UnitId, TU.UnitID) AS ToStockUnit,
							dbo.FN_GetUnitConvertionRate(R.PropertyID, R.ProductionUnitID, RH.UnitId) AS ToRecipeUnit) CR
		CROSS APPLY (SELECT CASE WHEN R.ProductionType = 'Manual' THEN 1
								 ELSE ISNULL(IR.Quantity, 1) * CASE WHEN CR.ToRecipeUnit > 0 THEN CR.ToRecipeUnit END
								 END AS RecipeFactor) F
		CROSS APPLY (SELECT R.ProductionQty * RD.Quantity * F.RecipeFactor
							* CASE WHEN CR.ToStockUnit > 0 THEN CR.ToStockUnit END AS Qty) Q
		WHERE (@RawMaterialID = -999 OR RD.StockItemId = @RawMaterialID)
		GROUP BY R.ProductionHeaderID, RD.StockItemId, TU.UnitID
	),
	ActLines AS
	(
		SELECT
			R.ProductionHeaderID,
			ID.StockItemID	AS RawMaterialID,
			TU.UnitID,
			CASE WHEN COUNT(*) = COUNT(Q.Qty) THEN SUM(Q.Qty) END AS ActualQty
		FROM Runs R
		INNER JOIN StockTransactionHeaders PI ON PI.ReferenceID = R.ProductionHeaderID
											 AND PI.TransactionType = 'PI'
											 AND PI.PropertyID = R.PropertyID
											 AND PI.LocationID = R.LocationID
											 AND PI.TransactionDate = R.TransactionDate
											 AND PI.Id > R.ProductionHeaderID
		INNER JOIN StockTransactionDetails ID ON ID.StockTransactionHeaderID = PI.Id
		CROSS APPLY (SELECT ISNULL(dbo.FN_GetMasterUnitID(R.PropertyID, R.LocationID, ID.StockItemID), ID.TxnUnitID) AS UnitID) TU
		CROSS APPLY (SELECT dbo.FN_GetUnitConvertionRate(R.PropertyID, ID.TxnUnitID, TU.UnitID) AS ToStockUnit) CR
		CROSS APPLY (SELECT ID.Quantity * CASE WHEN CR.ToStockUnit > 0 THEN CR.ToStockUnit END AS Qty) Q
		WHERE (@RawMaterialID = -999 OR ID.StockItemID = @RawMaterialID)
		GROUP BY R.ProductionHeaderID, ID.StockItemID, TU.UnitID
	)
	SELECT
		R.ProductionHeaderID,
		R.PropertyID,
		R.LocationID,
		R.TransactionDate,
		R.FinishedItemID,
		R.ProductionQty,
		R.ProductionUnitID,
		R.ProductionType,
		R.IsRecipeLocationMaintain,
		COALESCE(S.RawMaterialID, A.RawMaterialID)	AS RawMaterialID,	-- NULL = run with no recipe and nothing issued
		COALESCE(S.UnitID, A.UnitID)				AS UnitID,
		CASE WHEN S.RawMaterialID IS NULL THEN 0 ELSE S.StandardQty / NULLIF(R.ProductionQty, 0) END AS RecipeQty,
		CASE WHEN S.RawMaterialID IS NULL THEN 0 ELSE S.StandardQty END AS StandardQty,
		CASE WHEN A.RawMaterialID IS NULL THEN 0 ELSE A.ActualQty END AS ActualQty,
		CASE WHEN (S.RawMaterialID IS NOT NULL AND S.StandardQty IS NULL)
			   OR (A.RawMaterialID IS NOT NULL AND A.ActualQty IS NULL) THEN NULL
			 ELSE ISNULL(A.ActualQty, 0) - ISNULL(S.StandardQty, 0)
		END AS VarianceQty											-- actual - standard; + means over-issued
	FROM Runs R
	LEFT JOIN (StdLines S
			   FULL OUTER JOIN ActLines A ON A.ProductionHeaderID = S.ProductionHeaderID
										 AND A.RawMaterialID = S.RawMaterialID
										 AND A.UnitID = S.UnitID)
		   ON R.ProductionHeaderID = COALESCE(S.ProductionHeaderID, A.ProductionHeaderID)
)

GO

