
-- [dbo].[SP_ItemWiseMonthlyUsagePO] 128,1
CREATE PROCEDURE [dbo].[SP_ItemWiseMonthlyUsagePO] (@StockItemId INT , @PropertyId INT)

AS
BEGIN

	CREATE TABLE #TempItemUsage(
	Monthly		VARCHAR(150),
	TxnType		VARCHAR(10),
	Qty			MONEY,
	Value		MONEY,
	GRQty		MONEY,
	GRValue		MONEY,
	IssueQty	MONEY,
	IssueValue  MONEY,
	DamageQty   MONEY,
	DamageValue MONEY

	)

	INSERT INTO  #TempItemUsage
	SELECT CASE WHEN ( DATEPART(MONTH ,STH.TransactionDate) = DATEPART(MONTH , GETDATE())) THEN 'T' ELSE 'L' END AS Monthly , STH.TransactionType AS TxnType,	
	CASE WHEN STH.TransactionType = 'GR' THEN SUM(STD.Quantity) WHEN STH.TransactionType = 'SR' 
	THEN SUM(-STD.Quantity) WHEN STH.TransactionType = 'IN' THEN SUM(STD.Quantity) WHEN STH.TransactionType = 'IR' 
	THEN SUM(-STD.Quantity) WHEN  STH.TransactionType = 'DN' THEN SUM(STD.Quantity)  END  AS Qty ,
	CASE WHEN  STH.TransactionType = 'GR' THEN SUM(STD.Quantity * STD.UnitPrice) WHEN STH.TransactionType = 'SR' 
	THEN  SUM(-STD.Quantity * STD.UnitPrice) WHEN  STH.TransactionType = 'IN' THEN SUM(STD.Quantity * STD.UnitPrice) WHEN STH.TransactionType = 'IR' 
	THEN SUM(-STD.Quantity * STD.UnitPrice) WHEN STH.TransactionType = 'DN' THEN SUM(STD.Quantity * STD.UnitPrice) END  AS Value,
	0 AS GRQty, 0 AS GRValue, 0 AS IssueQty, 0 AS IssueValue, 0 AS DamageQty, 0 AS DamageValue
	FROM dbo.StockTransactionHeaders STH 
	LEFT JOIN dbo.StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.Id
	WHERE STD.StockItemID = @StockItemId  AND (( DATEPART(MONTH ,STH.TransactionDate) = DATEPART(MONTH , GETDATE())) OR (DATEPART(MONTH ,STH.TransactionDate) = DATEPART(MONTH , GETDATE())-1) )
	AND (STH.TransactionType = 'GR'  OR STH.TransactionType = 'SR'  OR  STH.TransactionType = 'IR' OR STH.TransactionType = 'IN' OR STH.TransactionType = 'DN' )
	AND STH.PropertyID = @PropertyId
	GROUP BY STH.TransactionType, CASE WHEN ( DATEPART(MONTH ,STH.TransactionDate) = DATEPART(MONTH , GETDATE()))
	THEN 'T' ELSE 'L' END

--SELECT * FROM #TempItemUsage

	UPDATE #TempItemUsage SET TxnType = CASE WHEN TxnType = 'SR' THEN  'GR' WHEN TxnType = 'IR' THEN 'IN'  WHEN TxnType = 'GR' THEN 'GR' WHEN TxnType = 'DN' THEN 'DN' ELSE 'IN'  END

	DECLARE @GRQtyT MONEY, @GRValueT MONEY, @IssueQtyT MONEY, @IssueValueT MONEY, @DamageQtyT MONEY, @DamageValueT MONEY,@MonthlyT VARCHAR(150) = 'THIS MONTH',
	@GRQtyL MONEY, @GRValueL MONEY, @IssueQtyL MONEY, @IssueValueL MONEY, @DamageQtyL MONEY, @DamageValueL MONEY,@MonthlyL VARCHAR(150) = 'LAST MONTH'

	--SELECT * FROM #TempItemUsage

	SELECT @GRQtyT = SUM(Qty), @GRValueT = SUM(Value)  FROM #TempItemUsage WHERE TxnType = 'GR' AND Monthly = 'T' GROUP BY Monthly,TxnType
    SELECT @IssueQtyT = SUM(Qty), @IssueValueT = SUM(Value)  FROM #TempItemUsage WHERE TxnType = 'IN' AND Monthly = 'T' GROUP BY Monthly,TxnType
	SELECT @DamageQtyT = SUM(Qty), @DamageValueT = SUM(Value)  FROM #TempItemUsage WHERE TxnType = 'DN' AND Monthly = 'T' GROUP BY Monthly,TxnType


	SELECT @GRQtyL = SUM(Qty), @GRValueL = SUM(Value)  FROM #TempItemUsage WHERE TxnType = 'GR' AND Monthly = 'L' GROUP BY Monthly,TxnType
    SELECT @IssueQtyL = SUM(Qty), @IssueValueL = SUM(Value)  FROM #TempItemUsage WHERE TxnType = 'IN' AND Monthly = 'L' GROUP BY Monthly,TxnType
	SELECT @DamageQtyL = SUM(Qty), @DamageValueL = SUM(Value)  FROM #TempItemUsage WHERE TxnType = 'DN' AND Monthly = 'L' GROUP BY Monthly,TxnType


	SELECT NULL AS SupplierId, '' AS SupplierCode, '' AS SupplierName,NULL AS SupplierPrice,NULL AS SuppWiseQTY, NULL AS SuppWiseValue,@MonthlyT AS Monthly,
	@GRQtyT AS GRQty, @GRValueT AS GRValue, @IssueQtyT AS IsuueQty, @IssueValueT AS IssueValue,@DamageQtyT AS DamageQty,
	@DamageValueT AS DamageValue
	UNION
	SELECT NULL AS SupplierId, '' AS SupplierCode, '' AS SupplierName,NULL AS SupplierPrice,NULL AS SuppWiseQTY, NULL AS SuppWiseValue,@MonthlyL AS Monthly,
	@GRQtyL AS GRQty, @GRValueL AS GRValue, @IssueQtyL AS IssueQty, @IssueValueL AS IssueValue,@DamageQtyL AS DamageQty,
	@DamageValueL AS DamageValue ORDER BY Monthly DESC



END

GO

