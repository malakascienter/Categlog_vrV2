--	[dbo].[SP_SupplierWiseMonthlyUsagePO] 1,1,1

CREATE PROCEDURE [dbo].[SP_SupplierWiseMonthlyUsagePO] (@StockItemId INT, @PropertyId INT,@LocationId INT)

AS
BEGIN

	CREATE TABLE #TempSuppier(
		SupplierId		INT ,
		SupplierCode	VARCHAR(15),	
		SupplierName	VARCHAR(200),
		SupplierPrice	MONEY,
		QTY				MONEY,
		TxnType			VARCHAR(10),
		Value MONEY,
		IsContractedSupplier BIT,
		Validfrom VARCHAR(MAX),
		ValidTo VARCHAR(MAX),
		LocationID INT
		

	)

	DECLARE @IsContractedSupplier BIT

	SELECT @IsContractedSupplier = IsContractedSupplier
	FROM Companies
	WHERE CompanyID = @PropertyId

	INSERT INTO #TempSuppier
	SELECT S.ID AS SupplierId, S.Code  AS SupplierCode, S.Name AS SupplierName, SWI.CostPrice AS SupplierPrice,
	CASE WHEN STH.TransactionType = 'GR' THEN SUM(STD.Quantity) WHEN STH.TransactionType = 'SR' 
	THEN SUM(-STD.Quantity) END  AS QTY , STH.TransactionType, 
	CASE WHEN  STH.TransactionType = 'GR' THEN SUM(STD.Quantity * STD.UnitPrice) WHEN STH.TransactionType = 'SR' 
	THEN SUM(-STD.Quantity * STD.UnitPrice) END  AS Value
	,ISNULL(SWI.IsContractedSupplier,0) IsContractedSupplier
	,CAST(SWI.Validfrom AS VARCHAR(MAX)) Validfrom
	,CAST(SWI.ValidTo AS VARCHAR(MAX)) ValidTo
	,SWI.LocationId
	FROM dbo.SupplierWiseItemDetails SWI
	INNER JOIN dbo.Suppliers S ON  S.ID = SWI.SupplierID AND SWI.StockItemID = @StockItemId AND SWI.CompanyId = @PropertyId
	LEFT JOIN dbo.StockTransactionHeaders STH ON STH.SupplierID = SWI.SupplierID AND DATEPART(MONTH ,STH.TransactionDate) = DATEPART(MONTH , GETDATE()) 
	AND STH.LocationID = SWI.LocationId
	LEFT JOIN dbo.StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.Id AND STD.StockItemID = @StockItemId
	--WHERE STD.StockItemID = @StockItemId  AND DATEPART(MONTH ,STH.TransactionDate) = DATEPART(MONTH , GETDATE()) 
	--AND (STH.TransactionType = 'GR'  OR STH.TransactionType = 'SR'  ) AND STH.PropertyID = @PropertyId
	WHERE SWI.LocationId = CASE WHEN SWI.LocationId = -999 THEN  @LocationId ELSE SWI.LocationId END
	GROUP BY S.ID ,S.Code,S.Name,SWI.CostPrice,  STH.TransactionType,SWI.IsContractedSupplier,SWI.Validfrom,SWI.ValidTo,SWI.LocationId

	--SELECT * FROM #TempSuppier

	IF(@IsContractedSupplier = 1)
	BEGIN

	
		SELECT SupplierId,SupplierCode,SupplierName,SupplierPrice, SUM(QTY) AS SuppWiseQTY , SUM(Value) AS SuppWiseValue ,
		'T' AS Monthly,NULL AS GRQty, NULL AS GRValue,NULL AS IssueQty, NULL AS IssueValue,NULL AS DamageQty, NULL AS DamageValue
		,IsContractedSupplier,Validfrom,ValidTo,LocationId
		FROM #TempSuppier 
		WHERE LocationID = CASE WHEN @LocationId = -999 THEN  LocationId ELSE @LocationId END
		GROUP BY SupplierId,SupplierCode,SupplierName,SupplierPrice,IsContractedSupplier,Validfrom,ValidTo,LocationId
		ORDER BY IsContractedSupplier DESC,SupplierPrice ASC
	END
	ELSE
	BEGIN
		SELECT SupplierId,SupplierCode,SupplierName,SupplierPrice, SUM(QTY) AS SuppWiseQTY , SUM(Value) AS SuppWiseValue ,
		'T' AS Monthly,NULL AS GRQty, NULL AS GRValue,NULL AS IssueQty, NULL AS IssueValue,NULL AS DamageQty, NULL AS DamageValue
		,IsContractedSupplier,Validfrom,ValidTo,LocationId
		FROM #TempSuppier 
		WHERE LocationID = CASE WHEN @LocationId = -999 THEN  LocationId ELSE @LocationId END
		GROUP BY SupplierId,SupplierCode,SupplierName,SupplierPrice,IsContractedSupplier,Validfrom,ValidTo,LocationId

	END
END

GO

