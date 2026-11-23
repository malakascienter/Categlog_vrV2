-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-28
-- Description:	Supplier Grading approval - graded documents of one submit as a grid
--              (one column per criteria) with CriteriaJson per document
-- [dbo].[SP_GetSupplierGradingApprovalDetail] 3
-- =============================================
create PROCEDURE [dbo].[SP_GetSupplierGradingApprovalDetail]
	@EvaluationHeaderID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @cols NVARCHAR(MAX), @sql NVARCHAR(MAX);

	-- criteria of this submit, in criteria order
	SELECT @cols = STRING_AGG(QUOTENAME(Criteria), ',') WITHIN GROUP (ORDER BY CriteriaID)
	FROM (SELECT DISTINCT EC.ID AS CriteriaID, EC.Criteria
		  FROM dbo.SupplierEvaluationDetail D
		  INNER JOIN dbo.EvaluationCriteria EC ON EC.ID = D.CriteriaID
		  WHERE D.EvaluationHeaderID = @EvaluationHeaderID) X;

	IF @cols IS NULL
	BEGIN
		SELECT CAST(NULL AS INT) AS HeaderID WHERE 1 = 0;
		RETURN;
	END

	SET @sql = N'
	;WITH Docs AS (
		SELECT D.StockTransactionHeaderID,
			   MAX(D.Remarks) AS Remarks,
			   MAX(D.ApproverRemarks) AS ApproverRemarks,
			   MAX(CASE WHEN D.OriginalScore IS NOT NULL THEN 1 ELSE 0 END) AS IsChangedByApprover
		FROM dbo.SupplierEvaluationDetail D
		WHERE D.EvaluationHeaderID = @H
		GROUP BY D.StockTransactionHeaderID
	),
	Amounts AS (
		SELECT SH.Id AS HeaderID,
			   SUM(SD.Quantity * SD.UnitPrice)
				 - SUM(CASE WHEN SD.DiscountValue = 0
							THEN SD.Quantity * SD.UnitPrice * SD.DiscountPercentage / 100
							ELSE SD.DiscountValue END)
				 + SUM(ISNULL(ST.TaxAmount, 0))
				 + ISNULL(SUM(SC.ChargeAmount), 0) AS TOTAL
		FROM dbo.StockTransactionHeaders SH WITH (NOLOCK)
		INNER JOIN Docs DC ON DC.StockTransactionHeaderID = SH.Id
		INNER JOIN dbo.StockTransactionDetails SD WITH (NOLOCK) ON SD.StockTransactionHeaderID = SH.Id
		LEFT JOIN dbo.StockTransactionwiseTaxes ST WITH (NOLOCK) ON ST.StockTransactionDetailID = SD.Id AND ST.StockItemID = SD.StockItemID
		LEFT JOIN dbo.StockTransactionwiseCharges SC WITH (NOLOCK) ON SC.StockTransactionHeaderID = SH.Id
		GROUP BY SH.Id
	),
	Src AS (
		SELECT SH.Id AS HeaderID,
			   SH.DocumentNo,
			   LO.Name AS LocationName,
			   SH.LocationID,
			   SH.TransactionDate,
			   SH.ReferenceNo,
			   A.TOTAL,
			   SH.TransactionType,
			   CASE WHEN SH.TransactionType = ''SR'' THEN 1 ELSE 0 END AS IsSupplierReturn,
			   DC.Remarks,
			   DC.ApproverRemarks,
			   DC.IsChangedByApprover,
			   EC.Criteria,
			   D.Score
		FROM Docs DC
		INNER JOIN dbo.StockTransactionHeaders SH WITH (NOLOCK) ON SH.Id = DC.StockTransactionHeaderID
		LEFT JOIN dbo.Locations LO WITH (NOLOCK) ON LO.Id = SH.LocationID
		LEFT JOIN Amounts A ON A.HeaderID = SH.Id
		INNER JOIN dbo.SupplierEvaluationDetail D ON D.EvaluationHeaderID = @H AND D.StockTransactionHeaderID = SH.Id
		INNER JOIN dbo.EvaluationCriteria EC ON EC.ID = D.CriteriaID
	)
	SELECT PV.*,
		   (SELECT D2.CriteriaID, EC2.Criteria, D2.MaxMarks, D2.Score, D2.OriginalScore
			FROM dbo.SupplierEvaluationDetail D2
			INNER JOIN dbo.EvaluationCriteria EC2 ON EC2.ID = D2.CriteriaID
			WHERE D2.EvaluationHeaderID = @H AND D2.StockTransactionHeaderID = PV.HeaderID
			ORDER BY D2.CriteriaID
			FOR JSON PATH) AS CriteriaJson
	FROM Src
	PIVOT (MAX(Score) FOR Criteria IN (' + @cols + N')) AS PV
	ORDER BY PV.TransactionDate, PV.HeaderID;';

	EXEC sp_executesql @sql, N'@H INT', @H = @EvaluationHeaderID;
END

GO

