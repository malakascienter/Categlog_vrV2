-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-05-02
-- Description:	Loading Procurement Supplier Details

-- [dbo].[SP_SelectEvaluationCriteria] 1285,1,1

-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectEvaluationCriteria]
	@SupplierID INT,
	@PropertyID INT,
	@ID INT =0
AS
BEGIN
	SET NOCOUNT ON;


		SELECT PR.ID ProcurementID,pr.LocationID,sq.SupplierID,sq.ID SupplierQuotationID,ET.EvaluationTemplateName,EC.Criteria,EC.MaxMarks
		,PC.AssignedScore,EC.ID CriteriaID,EC.EvaluationTemplateID
		,SQ.QuotationFile
		FROM ProcurementRequest PR 
		INNER JOIN SupplierQuotation SQ ON PR.ID = SQ.ProcurementID
		INNER JOIN EvaluationTemplate ET ON ET.ID = PR.EvaluationCriteriaID
		INNER JOIN EvaluationCriteria EC ON EC.EvaluationTemplateID = ET.ID
		LEFT JOIN ProcurementEvaluation PC ON PC.ProcurementID = PR.ID AND PC.SupplierID = SQ.SupplierID AND PC.EvaluationCriteriaID = EC.ID
		WHERE SQ.SupplierID = @SupplierID
		AND PR.ID = @ID
		AND PR.CompanyID = @PropertyID
		AND PR.IsApprove =1
		--AND PR.StatusID =1

		
END

GO

