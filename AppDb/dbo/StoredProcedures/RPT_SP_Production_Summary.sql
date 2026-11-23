-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-10-14
-- Description:	Production Summary Report (RPT_ProductionSummaryReport)
--				Finished item wise number of production runs and total quantity
--				produced in the period. 
--
--  [dbo].[RPT_SP_Production_Summary] 1, -999, '2026-01-01', '2026-12-31', -999

-- =============================================
CREATE   PROCEDURE [dbo].[RPT_SP_Production_Summary]
	@PropertyID	 INT,
	@LocationID	 INT,
	@FromDate	 DATETIME,
	@ToDate		 DATETIME,
	@StockItemID INT = -999		-- finished item
AS
BEGIN

	SET NOCOUNT ON;

	SET @LocationID  = ISNULL(@LocationID, -999);
	SET @StockItemID = ISNULL(@StockItemID, -999);

	SELECT
		SH.StockItemCode		AS FinishedItemCode,
		SH.Name					AS FinishedItem,
		COUNT(DISTINCT PU.Id)	AS NoOfRuns,
		SUM(PD.Quantity)		AS TotalQtyProduced,
		ISNULL(U.Name, '-')		AS UOM
	FROM StockTransactionHeaders PU
	INNER JOIN StockTransactionDetails PD ON PD.StockTransactionHeaderID = PU.Id
	INNER JOIN StockItemHeaders SH ON SH.Id = PD.StockItemID
	LEFT JOIN Units U ON U.Id = PD.TxnUnitID
	WHERE PU.TransactionType = 'PU'
	  AND PU.PropertyID = @PropertyID
	  AND (@LocationID = -999 OR PU.LocationID = @LocationID)
	  AND PU.TransactionDate BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
	  AND (@StockItemID = -999 OR PD.StockItemID = @StockItemID)
	GROUP BY SH.Id, SH.StockItemCode, SH.Name, PD.TxnUnitID, U.Name
	ORDER BY SH.Name, U.Name;

END

GO

