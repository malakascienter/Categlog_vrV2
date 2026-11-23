
-- =============================================
-- Author:		Isuru
-- Create date: 2026-09-25
-- Description:	Auto Order Suggestion of ONE item, worked out exactly like the
--				AutoOrderSuggestion column of RPT_ParLevelReport (same parameters).
--				Every variable has the type of the report column it stands for, so each
--				step rounds the same way and the result matches the report to 6 decimals.
--				Returns NULL when @ItemID is -999 / NULL, or when the item is not on the
--				report for that location, supplier and company.
--				If the formula in RPT_ParLevelReport changes, change it here too.
--
-- SELECT [dbo].[FN_GetParLevelAutoOrderSuggestion]('2026-08-24','2026-09-22',4,212,1,'2026-09-26',1234)
-- =============================================
CREATE FUNCTION [dbo].[FN_GetParLevelAutoOrderSuggestion]
(
	@FromDate VARCHAR(100),
	@ToDate VARCHAR(100),
	@LocationID INT,
	@SupplierID INT,
	@PropertyID INT,
	@DispatchDate VARCHAR(100),
	@ItemID INT
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	-- Same variables as RPT_ParLevelReport
	DECLARE @DateCount INT;
	DECLARE @DailyUsageAmount DECIMAL(18,6),@LeadDateCount INT

	SET @DailyUsageAmount = 1.5

	SET @DateCount = DATEDIFF(DAY,CAST(@FromDate AS DATE),  CAST(@ToDate AS DATE)) +1;
	SET @LeadDateCount = DATEDIFF(DAY, CAST(@ToDate AS DATE), CAST(@DispatchDate AS DATE));

	-- One item only; -999 means all items in the report
	IF @ItemID IS NULL OR @ItemID = -999
		RETURN NULL;

	-- The item's row of #TempSupplierWiseItems, one variable per column used
	DECLARE @InReport BIT = 0,
		@HoldingDays INT,
		@CurrentStock DECIMAL(18,6),
		@SaleQty DECIMAL(38,6),					-- #Usage.SaleQty (SUM of DECIMAL(18,6))
		@ItemDailyUsageAmount DECIMAL(18,6),	-- DailyUsageAmount column
		@ParLevel DECIMAL(18,6),
		@ReOrderLevel DECIMAL(18,6),
		@LeadTimeUsage DECIMAL(18,6),
		@AutoOrderSuggestion DECIMAL(18,6)

	-- Same item filter as the report
	SELECT TOP (1) @InReport = 1, @HoldingDays = LO.HoldingDays
	FROM SupplierWiseItemDetails SW
	INNER JOIN Locations LO ON  LO.ID = SW.LocationId
	INNER JOIN StockItemHeaders SIH ON SIH.ID = SW.StockItemID
	INNER JOIN StockItemDetails SID ON SID.StockItemHeaderID = SIH.Id AND LO.ID = SID.LocationID
	INNER JOIN Units UN ON UN.ID = SID.MasterUnitID
	WHERE SW.LocationId = @LocationID
	AND SW.SupplierID = @SupplierID
	AND SIH.CompanyId = @PropertyID
	AND SIH.ID = @ItemID

	IF @InReport = 0
		RETURN NULL;

	-- Current stock as at @ToDate: running balance on the item's last line up to that date
	SELECT TOP (1) @CurrentStock = STD.NewQuantity
	FROM StockTransactionHeaders STH
	INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.ID
	WHERE STH.LocationID = @LocationID
	AND STD.StockItemID = @ItemID
	AND STH.TransactionDate < DATEADD(DAY, 1, CAST(@ToDate AS DATE))
	ORDER BY STH.TransactionDate DESC, STH.CreatedDate DESC, STD.Id DESC

	SET @CurrentStock = ISNULL(@CurrentStock, 0)

	-- KIT ISSUE usage in the period
	SELECT @SaleQty = SUM(STD.Quantity)
	FROM StockTransactionHeaders STH
	INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.ID
	WHERE STH.LocationID = @LocationID
	AND STH.TransactionType = 'IF'
	AND STD.StockItemID = @ItemID
	AND STH.TransactionDate >= CAST(@FromDate AS DATE)
	AND STH.TransactionDate < DATEADD(DAY, 1, CAST(@ToDate AS DATE))

	SET @ItemDailyUsageAmount = (ISNULL(@SaleQty, 0) / NULLIF(@DateCount, 0)) * @DailyUsageAmount

	SET @ParLevel = @ItemDailyUsageAmount * @HoldingDays
	SET @ReOrderLevel = (@ItemDailyUsageAmount * @HoldingDays) * 35/100
	SET @LeadTimeUsage = @ItemDailyUsageAmount * @LeadDateCount

	SET @AutoOrderSuggestion = CASE WHEN @CurrentStock <= @ReOrderLevel
								THEN (@ParLevel - @CurrentStock) + @LeadTimeUsage ELSE 0 END

	RETURN @AutoOrderSuggestion;
END

GO

