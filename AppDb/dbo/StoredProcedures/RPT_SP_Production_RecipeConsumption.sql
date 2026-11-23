-- =============================================
-- Author:		Tharuka sachintha
-- Create date: 2026-10-14
-- Description:	Production Run - Recipe Consumption Report (RPT_ProductionRecipeConsumptionReport)

--  [dbo].[RPT_SP_Production_RecipeConsumption] 1, -999, '2026-01-01', '2026-12-31', -999, '-999'

-- =============================================
CREATE   PROCEDURE [dbo].[RPT_SP_Production_RecipeConsumption]
	@PropertyID		 INT,
	@LocationID		 INT,
	@FromDate		 DATETIME,
	@ToDate			 DATETIME,
	@StockItemID	 INT = -999,		-- finished item
	@ProductionRefID NVARCHAR(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @RefID INT = ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(@ProductionRefID)), '') AS INT), -999);

	SET @LocationID  = ISNULL(@LocationID, -999);
	SET @StockItemID = ISNULL(@StockItemID, -999);

	SELECT
		C.ProductionHeaderID,
		C.TransactionDate,
		PU.DocumentNo			AS ProductionRef,
		FI.StockItemCode		AS FinishedItemCode,
		FI.Name					AS FinishedItem,
		C.ProductionQty,
		ISNULL(PUU.Name, '-')	AS ProductionUOM,
		ISNULL(RM.StockItemCode, '-') AS RawMaterialCode,
		ISNULL(RM.Name, '-- No raw material consumption --') AS RawMaterial,
		C.RecipeQty,
		C.StandardQty,
		C.ActualQty,
		C.VarianceQty,
		ISNULL(U.Name, '-')		AS UOM,
		ISNULL(L.Name, '-')		AS Location,
		C.ProductionType
	FROM dbo.FN_RPT_ProductionRunConsumption(@PropertyID, @LocationID, @FromDate, @ToDate, @StockItemID, -999, @RefID) C
	INNER JOIN StockTransactionHeaders PU ON PU.Id = C.ProductionHeaderID
	INNER JOIN StockItemHeaders FI ON FI.Id = C.FinishedItemID
	LEFT JOIN StockItemHeaders RM ON RM.Id = C.RawMaterialID
	LEFT JOIN Units PUU ON PUU.Id = C.ProductionUnitID
	LEFT JOIN Units U ON U.Id = C.UnitID
	LEFT JOIN Locations L ON L.Id = C.LocationID
	ORDER BY C.TransactionDate, C.ProductionHeaderID, RM.Name;

END

GO

