-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-06-03
-- Description:	Loading Supplier Wise GRN for Grading with Criteria JSON

-- [dbo].[SP_GetSupplierGRNGrading] 1,1,3,'2025-05-29','2027-06-29'

-- =============================================
CREATE PROCEDURE  [dbo].[SP_GetSupplierGRNGrading]
	@PropertyID INT,
	@SupplierID INT,
	@EvaluationTemplateID INT,
	@FromDate DATE,
	@ToDate DATE
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cols NVARCHAR(MAX) = '';
	DECLARE @sql NVARCHAR(MAX) = '';
	DECLARE @CriteriaJson NVARCHAR(MAX);
	DECLARE @CriteriaJsonSR NVARCHAR(MAX); --added by isuru 2026-10-28

	-- Build list of pivot columns (criteria names)
	SELECT @cols = STRING_AGG(QUOTENAME(Criteria), ',')
	FROM EvaluationCriteria
	WHERE EvaluationTemplateID = @EvaluationTemplateID;

	-- Build JSON list of criteria once (GRN: default score = Max Marks, as before)
	SELECT @CriteriaJson = (
		SELECT
			EC.ID AS CriteriaID,
			EC.EvaluationTemplateID,
			EC.Criteria,
			EC.MaxMarks,
			EC.MaxMarks Score
		FROM EvaluationTemplate EV
		INNER JOIN EvaluationCriteria EC ON EV.ID = EC.EvaluationTemplateID
		WHERE EV.ID = @EvaluationTemplateID
		FOR JSON PATH
	);

	--added by isuru 2026-10-28: same list for Supplier Returns, default score 0
	SELECT @CriteriaJsonSR = (
		SELECT
			EC.ID AS CriteriaID,
			EC.EvaluationTemplateID,
			EC.Criteria,
			EC.MaxMarks,
			0 Score
		FROM EvaluationTemplate EV
		INNER JOIN EvaluationCriteria EC ON EV.ID = EC.EvaluationTemplateID
		WHERE EV.ID = @EvaluationTemplateID
		FOR JSON PATH
	);

	-- Build dynamic SQL for pivot with JSON column included
	SET @sql = '
	;WITH GRNData AS (
		SELECT
			SH.Id AS HeaderID,
			SH.DocumentNo,
			LO.Name AS LocationName,
			SU.Name AS SupplierName,
			SH.LocationID,
			SH.TransactionDate,
			SH.ReferenceNo,
			SH.Remarks,
			SH.TransactionType,
			CASE WHEN SH.TransactionType = ''SR'' THEN 1 ELSE 0 END AS IsSupplierReturn,
			SUM(SD.Quantity * SD.UnitPrice)
				- SUM(CASE
						WHEN SD.DiscountValue = 0
							THEN SD.Quantity * SD.UnitPrice * SD.DiscountPercentage / 100
						ELSE SD.DiscountValue
					  END)
				+ SUM(ISNULL(ST.TaxAmount, 0))
				+ ISNULL(SUM(SC.ChargeAmount), 0) AS TOTAL
		FROM StockTransactionHeaders SH WITH (NOLOCK)
		INNER JOIN StockTransactionDetails SD WITH (NOLOCK) ON SH.Id = SD.StockTransactionHeaderID
		INNER JOIN Locations LO WITH (NOLOCK) ON LO.Id = SH.LocationID
		INNER JOIN Suppliers SU WITH (NOLOCK) ON SU.ID = SH.SupplierID
		LEFT JOIN StockTransactionwiseTaxes ST WITH (NOLOCK) ON ST.StockTransactionDetailID = SD.Id AND ST.StockItemID = SD.StockItemID
		LEFT JOIN StockTransactionwiseCharges SC WITH (NOLOCK) ON SC.StockTransactionHeaderID = SH.Id
		WHERE SH.TransactionType IN (''GR'', ''SR'') --changed by isuru 2026-10-28: Supplier Returns too
			AND SH.SupplierID = ' + CAST(@SupplierID AS NVARCHAR) + '
			AND SH.PropertyID = ' + CAST(@PropertyID AS NVARCHAR) + '
			AND SH.TransactionDate BETWEEN ''' + CONVERT(NVARCHAR, @FromDate, 23) + ''' AND ''' + CONVERT(NVARCHAR, @ToDate, 23) + '''
		GROUP BY SH.Id, SH.DocumentNo, LO.Name, SU.Name, SH.LocationID, SH.TransactionDate, SH.ReferenceNo, SH.Remarks, SH.TransactionType
	),
	SupplierEvalHeader AS (
		SELECT *
		FROM dbo.SupplierEvaluationHeader
		WHERE PropertyID = ' + CAST(@PropertyID AS NVARCHAR) + '
		AND SupplierID = ' + CAST(@SupplierID AS NVARCHAR) + '
		AND EvaluationTemplateID = ' + CAST(@EvaluationTemplateID AS NVARCHAR) + '
	),
	SupplierEvalDetail AS (
		SELECT SED.*
		FROM dbo.SupplierEvaluationDetail SED
		INNER JOIN SupplierEvalHeader SEH ON SEH.ID = SED.EvaluationHeaderID
	),
	GrnWithScores AS (
		SELECT
			G.HeaderID,
			G.DocumentNo,
			G.LocationName,
			G.SupplierName,
			G.LocationID,
			G.TransactionDate,
			G.ReferenceNo,
			SED.Remarks,
			G.TOTAL,
			G.TransactionType,
			G.IsSupplierReturn,
			EC.Criteria,
			-- Use saved score if present, else max marks for a GRN / 0 for a Supplier Return (changed by isuru 2026-10-28)
			ISNULL(SED.Score, CASE WHEN G.IsSupplierReturn = 1 THEN CAST(0 AS DECIMAL(18,2))
								   ELSE CAST(EC.MaxMarks AS DECIMAL(18,2)) END) AS Score,
			CASE WHEN EXISTS (
			SELECT 1
			FROM SupplierEvalDetail SED2
			WHERE SED2.StockTransactionHeaderID = G.HeaderID
		) THEN 1 ELSE 0 END AS IsEvaluated
		FROM GRNData G
		CROSS JOIN EvaluationCriteria EC
		LEFT JOIN SupplierEvalDetail SED ON SED.StockTransactionHeaderID = G.HeaderID AND SED.CriteriaID = EC.ID
		WHERE EC.EvaluationTemplateID = ' + CAST(@EvaluationTemplateID AS NVARCHAR) + '
	)
	SELECT
		HeaderID,
		DocumentNo,
		LocationName,
		SupplierName,
		LocationID,
		TransactionDate,
		ReferenceNo,
		Remarks,
		TOTAL, ' + @cols + ',
		IsEvaluated,
		0 IsSelectedRow,
		TransactionType,
		IsSupplierReturn,
		CASE WHEN IsSupplierReturn = 1
			 THEN ''' + REPLACE(ISNULL(@CriteriaJsonSR, ''), '''', '''''') + '''
			 ELSE ''' + REPLACE(ISNULL(@CriteriaJson, ''), '''', '''''') + ''' END AS CriteriaJson
	FROM GrnWithScores
	PIVOT (
		MAX(Score)
		FOR Criteria IN (' + @cols + ')
	) AS PivotedGRN
	ORDER BY TransactionDate, HeaderID;
	';

	EXEC sp_executesql @sql;
END

GO

