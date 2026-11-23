-- =============================================
-- Author:		Isuru
-- Create date: 2026-09-22
-- Description:	SP for Par Level Report

-- [dbo].[RPT_ParLevelReport] '2026-08-24','2026-09-22',4,212,1,'2026-09-22',-999

-- =============================================
create   PROCEDURE [dbo].[RPT_ParLevelReport] 
	@FromDate VARCHAR(100),
	@ToDate VARCHAR(100),
	@LocationID INT,
	@SupplierID INT,
	@PropertyID INT,
	@DispatchDate VARCHAR(100),
	@ItemID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @DateCount INT;
	DECLARE @DailyUsageAmount DECIMAL(18,6),@LeadDateCount INT

	SET @DailyUsageAmount = 1.5

	SET @DateCount = DATEDIFF(DAY,CAST(@FromDate AS DATE),  CAST(@ToDate AS DATE)) +1;
	SET @LeadDateCount = DATEDIFF(DAY, CAST(@ToDate AS DATE), CAST(@DispatchDate AS DATE));


	

	CREATE TABLE #TempSupplierWiseItems (StockItemID INT,StockItemCode VARCHAR(MAX),ItemName VARCHAR(MAX),SupplierID INT,CurrentStock DECIMAL(18,6),
	LocationId INT,UnitName VARCHAR(MAX),MasterUnitID INT,SaleQty DECIMAL(18,6),AvgDailyUsage DECIMAL(18,6)
	,DailyUsageAmount DECIMAL(18,6),OutletType VARCHAR(MAX),HoldingDays INT,ParLevel DECIMAL(18,6),ReOrderLevel DECIMAL(18,6) 
	,OrderDate DATE,DispatchDate DATE,LeadDaysCount INT,LeadTimeUsage DECIMAL(18,6),FinalOrderQty DECIMAL(18,6)
	,StockCoverageDays DECIMAL(18,6),StockStatus VARCHAR(MAX),AutoOrderSuggestion DECIMAL(18,6)
	)

	INSERT INTO #TempSupplierWiseItems(StockItemID,StockItemCode,ItemName,SupplierID,CurrentStock,LocationId,UnitName,MasterUnitID,HoldingDays
	,OrderDate,DispatchDate,LeadDaysCount)
	SELECT SW.StockItemID,SIH.StockItemCode,SIH.Name ItemName,SW.SupplierID SupplierID,0 CurrentStock,LO.Id LocationId,UN.Name UnitName,SID.MasterUnitID,LO.HoldingDays
	,CONVERT(DATE,@ToDate) OrderDate,CONVERT(DATE,@DispatchDate) DispatchDate,@LeadDateCount  LeadDaysCount
	
	FROM SupplierWiseItemDetails SW
	INNER JOIN Locations LO ON  LO.ID = SW.LocationId
	INNER JOIN StockItemHeaders SIH ON SIH.ID = SW.StockItemID
	INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND LO.ID = SID.LocationID
	INNER JOIN Units UN ON UN.ID = SID.MasterUnitID
	WHERE SW.LocationId = @LocationID
	AND SW.SupplierID = @SupplierID
	AND SIH.CompanyId = @PropertyID 
	AND SIH.ID = CASE WHEN @ItemID = -999 THEN SIH.ID ELSE @ItemID END


	;WITH StockAsAt AS
	(
		SELECT STD.StockItemID, STD.NewQuantity,
			ROW_NUMBER() OVER (PARTITION BY STD.StockItemID
							   ORDER BY STH.TransactionDate DESC, STH.CreatedDate DESC, STD.Id DESC) AS rn
		FROM StockTransactionHeaders STH
		INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.ID
		WHERE STH.LocationID = @LocationID
		AND STH.TransactionDate < DATEADD(DAY, 1, CAST(@ToDate AS DATE))
	)
	UPDATE TW
	SET TW.CurrentStock = ISNULL(B.NewQuantity, 0)
	FROM #TempSupplierWiseItems TW
	LEFT JOIN StockAsAt B ON B.StockItemID = TW.StockItemID AND B.rn = 1
	OPTION (RECOMPILE);

	--UPDATE TW
	--SET  TW.SaleQty = ISNULL(X.SaleQty, 0),
 --   TW.AvgDailyUsage = ISNULL(X.SaleQty, 0) / NULLIF(@DateCount, 0),
 --   TW.DailyUsageAmount = 
 --       (ISNULL(X.SaleQty, 0) / NULLIF(@DateCount, 0)) * @DailyUsageAmount
	--FROM #TempSupplierWiseItems TW
	--LEFT JOIN
	--(
	--SELECT 
	--STD.StockItemID,STH.LocationID,SUM(ISNULL(STD.Quantity, 0)) AS SaleQty
	--FROM StockTransactionHeaders STH
	--INNER JOIN StockTransactionDetails STD 
	--ON STH.ID = STD.StockTransactionHeaderID
	--WHERE STH.LocationID = @LocationID
	--AND STH.TransactionType = 'IF'
	--AND STH.TransactionDate >= CAST(@FromDate AS DATE)
	--AND STH.TransactionDate < DATEADD(DAY, 1, CAST(@ToDate AS DATE))
	--GROUP BY 
	--STD.StockItemID,
	--STH.LocationID
	--) X
	--ON X.StockItemID = TW.StockItemID
	--AND X.LocationID = TW.LocationId;

	-- 2026-09-24: total KIT ISSUE usage once, so the plan no longer depends on the item count
	SELECT STD.StockItemID, SUM(STD.Quantity) AS SaleQty
	INTO #Usage
	FROM StockTransactionHeaders STH
	INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.ID
	WHERE STH.LocationID = @LocationID
	AND STH.TransactionType = 'IF'
	AND STH.TransactionDate >= CAST(@FromDate AS DATE)
	AND STH.TransactionDate < DATEADD(DAY, 1, CAST(@ToDate AS DATE))
	GROUP BY STD.StockItemID
	OPTION (RECOMPILE);

	UPDATE TW
	SET TW.SaleQty = ISNULL(U.SaleQty, 0),
		TW.AvgDailyUsage = ISNULL(U.SaleQty, 0) / NULLIF(@DateCount, 0),
		TW.DailyUsageAmount = (ISNULL(U.SaleQty, 0) / NULLIF(@DateCount, 0)) * @DailyUsageAmount
	FROM #TempSupplierWiseItems TW
	LEFT JOIN #Usage U ON U.StockItemID = TW.StockItemID;




	UPDATE #TempSupplierWiseItems
	SET ParLevel = DailyUsageAmount * HoldingDays,
	ReOrderLevel  = (DailyUsageAmount * HoldingDays) * 35/100,
	LeadTimeUsage = DailyUsageAmount * @LeadDateCount


	UPDATE #TempSupplierWiseItems
	SET --FinalOrderQty = (ParLevel - CurrentStock) + LeadTimeUsage,
	FinalOrderQty = CASE WHEN CurrentStock <= ReOrderLevel
                            THEN (ParLevel - CurrentStock) + LeadTimeUsage ELSE 0 END,
	StockCoverageDays = CurrentStock / NULLIF(DailyUsageAmount, 0),
	StockStatus = CASE WHEN ReOrderLevel >= CurrentStock THEN 'REORDER REQUIRED'  WHEN CurrentStock >= ParLevel THEN 'OVERSTOCK' ELSE 'NORMAL' END
	--,AutoOrderSuggestion = (ParLevel - CurrentStock) + LeadTimeUsage
	,AutoOrderSuggestion= CASE WHEN CurrentStock <= ReOrderLevel
                            THEN (ParLevel - CurrentStock) + LeadTimeUsage ELSE 0 END

	SELECT *
	FROM #TempSupplierWiseItems



END

GO

