
-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-10-29
-- Description:	Grade of the latest completed Supplier Grading submit of a supplier
            
-- SELECT * FROM dbo.FN_GetSupplierLatestGrade(1)

-- =============================================
CREATE FUNCTION [dbo].[FN_GetSupplierLatestGrade]
(
	@SupplierID INT
)
RETURNS TABLE
AS
RETURN
(
	SELECT TOP (1)
		H.ID AS EvaluationHeaderID,
		H.DocumentNumber,
		H.SupplierGrade,
		H.GradePercentage,
		P.PeriodFrom,
		P.PeriodTo
	FROM dbo.SupplierEvaluationHeader H WITH (NOLOCK)
	OUTER APPLY (
		SELECT MIN(SD.TransactionDate) AS PeriodFrom,
			   MAX(SD.TransactionDate) AS PeriodTo
		FROM dbo.SupplierEvaluationDetail SD WITH (NOLOCK)
		WHERE SD.EvaluationHeaderID = H.ID
		  AND SD.TransactionType = 'GRN'
	) P
	WHERE H.SupplierID = @SupplierID
	  AND H.IsApproved = 1
	  AND H.DocumentStatus = 'C'
	  AND H.SupplierGrade IS NOT NULL
	ORDER BY P.PeriodTo DESC, H.CreatedDate DESC, H.ID DESC
);

GO

