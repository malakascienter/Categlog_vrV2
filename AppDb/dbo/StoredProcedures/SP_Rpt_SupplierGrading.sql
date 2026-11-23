-- =============================================
-- Author:		Nivesh
-- Create date: 2025-07-22
-- Description:	Supplier Grading
-- =============================================
-- SP_Rpt_SupplierGrading 1, -999, '2025-07-22', '2025-07-22'

CREATE PROCEDURE SP_Rpt_SupplierGrading 
	@PropertyID INT,
	@SupplierID INT,
	@ToDate DATE,
	@FromDate DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


  SELECT S.Name AS SupplierName,
  S.Code AS SupplierCode,
  ET.EvaluationTemplateName,
  SUM(SED.Score) Total,
 (SELECT COUNT(*) FROM(
		SELECT SED1.EvaluationHeaderID,SED1.StockTransactionHeaderID
		FROM SupplierEvaluationDetail SED1   
		INNER  JOIN SupplierEvaluationHeader SEH1  ON SEH1.ID = SED1.EvaluationHeaderID
		WHERE SEH1.SupplierID = SEH.SupplierID 
		GROUP BY SED1.EvaluationHeaderID,SED1.StockTransactionHeaderID
		)AS tempTable ) AS GRNCount 
	,
	ISNULL((
	SELECT ECR.Grade FROM
	EvaluationCriteriaRange ECR 
	WHERE ECR.EvaluationTemplateID = SEH.EvaluationTemplateID
	AND (SUM(SED.Score)/
	(SELECT COUNT(*) FROM(
		SELECT SED1.EvaluationHeaderID,SED1.StockTransactionHeaderID
		FROM SupplierEvaluationDetail SED1  
		INNER  JOIN SupplierEvaluationHeader SEH1  ON SEH1.ID = SED1.EvaluationHeaderID
		WHERE SEH1.SupplierID = SEH.SupplierID 
		GROUP BY SED1.EvaluationHeaderID,SED1.StockTransactionHeaderID
		)AS tempTable ))
		BETWEEN ECR.MarksFrom AND ECR.MarksTo),(SELECT TOP 1 Grade FROM
EvaluationCriteriaRange
WHERE EvaluationTemplateID = SEH.EvaluationTemplateID
ORDER BY MarksTo DESC) )AS Grade
	
	FROM SupplierEvaluationHeader SEH 
  INNER JOIN Suppliers S  ON S.ID = SEH.SupplierID
  INNER JOIN EvaluationTemplate ET  ON ET.ID = SEH.EvaluationTemplateID
  INNER JOIN SupplierEvaluationDetail SED  ON SED.EvaluationHeaderID = SEH.ID
  WHERE SEH.SupplierID = CASE WHEN @SupplierID = -999 THEN SEH.SupplierID ELSE @SupplierID END
  AND CONVERT(DATE,SEH.CreatedDate) BETWEEN @FromDate AND @ToDate
  AND SEH.PropertyID = @PropertyID
  GROUP BY SEH.SupplierID,S.Name,S.Code,SEH.SupplierID,ET.EvaluationTemplateName,SEH.EvaluationTemplateID

END

GO

