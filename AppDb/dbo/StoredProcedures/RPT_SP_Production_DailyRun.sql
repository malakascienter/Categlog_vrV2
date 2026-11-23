-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-10-14
-- Description:	Daily Production Run Report (RPT_DailyProductionRunReport)
--				Every production run (PU) in the period

--  [dbo].[RPT_SP_Production_DailyRun] 1, -999, '2026-01-01', '2026-12-31', -999, '-999'

-- =============================================
CREATE   PROCEDURE [dbo].[RPT_SP_Production_DailyRun]
	@PropertyID		 INT,
	@LocationID		 INT,
	@FromDate		 DATETIME,
	@ToDate			 DATETIME,
	@StockItemID	 INT = -999,
	@ProductionRefID NVARCHAR(50) = NULL
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE @RefID INT = ISNULL(TRY_CAST(NULLIF(LTRIM(RTRIM(@ProductionRefID)), '') AS INT), -999);

	SET @LocationID  = ISNULL(@LocationID, -999);
	SET @StockItemID = ISNULL(@StockItemID, -999);

	SELECT
		PU.Id				AS ProductionHeaderID,
		PU.TransactionDate,
		PU.DocumentNo		AS ProductionRef,
		SH.StockItemCode	AS FinishedItemCode,
		SH.Name				AS FinishedItem,
		PD.Quantity			AS QtyProduced,
		ISNULL(U.Name, '-')	AS UOM,
		ISNULL(L.Name, '-')	AS Location,
		ISNULL(CU.Username, '-') AS CreatedUser,
		-- same classification as FN_RPT_ProductionRunConsumption
		CASE WHEN PU.Remarks LIKE 'Pr%duction recipe%' THEN 'Manual'
			 WHEN PU.Remarks LIKE 'AUTO PU%' THEN 'Auto'
			 ELSE 'Plan / Other' END AS ProductionType
	FROM StockTransactionHeaders PU
	INNER JOIN StockTransactionDetails PD ON PD.StockTransactionHeaderID = PU.Id
	INNER JOIN StockItemHeaders SH ON SH.Id = PD.StockItemID
	LEFT JOIN Units U ON U.Id = PD.TxnUnitID
	LEFT JOIN Locations L ON L.Id = PU.LocationID
	LEFT JOIN CentralUsers CU ON CU.Id = PU.CreatedUserID
	WHERE PU.TransactionType = 'PU'
	  AND PU.PropertyID = @PropertyID
	  AND (@LocationID = -999 OR PU.LocationID = @LocationID)
	  AND PU.TransactionDate BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
	  AND (@StockItemID = -999 OR PD.StockItemID = @StockItemID)
	  AND (@RefID = -999 OR PU.Id = @RefID)
	ORDER BY PU.TransactionDate, PU.Id;

END

GO

