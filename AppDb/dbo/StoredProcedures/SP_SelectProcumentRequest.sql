-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-04-29
-- Description:	ProcurementRequest Select
-- [dbo].[SP_SelectProcumentRequest] -999,-999,'PO',408

-- =============================================

CREATE PROCEDURE [dbo].[SP_SelectProcumentRequest]
	@LocationID INT,
	@PropertyID INT,
	@Mode CHAR(2),
	@ID INT =0
AS
BEGIN
	SET NOCOUNT ON;

	 IF OBJECT_ID('tempdb..#ProcurementEvaluation') IS NOT NULL
            DROP TABLE #ProcurementEvaluation;

	IF(@Mode ='H')
	BEGIN
		SELECT PR.ID,PR.DocumentNo
		FROM ProcurementRequest PR
		WHERE PR.LocationID = CASE WHEN @LocationID = -999 THEN PR.LocationID ELSE @LocationID END
		AND PR.CompanyID = CASE WHEN @PropertyID = -999 THEN PR.CompanyID ELSE @PropertyID END
		AND PR.IsApprove =1
		AND PR.StatusID IN(1,4)
		AND PR.ID = CASE WHEN @ID = -999 THEN PR.ID ELSE @ID END
	END

	IF(@Mode ='D')
	BEGIN
		SELECT PR.ID,PR.LocationID,LO.Name Location,PR.DocumentNo,CONVERT(DATE,PR.InitiatedDate) InitiatedDate,PR.GeneralDescription,PR.EvaluationCriteriaID,EV.EvaluationTemplateName,
		PR.ItemID,PR.ItemName,PR.UnitID,UN.Name Unit,PR.Quantity
		FROM ProcurementRequest PR
		INNER JOIN LOCATIONS LO ON PR.LocationID = LO.ID
		INNER JOIN EvaluationTemplate EV ON EV.ID = PR.EvaluationCriteriaID
		INNER JOIN UNITS UN ON UN.ID = PR.UnitID
		WHERE PR.LocationID = CASE WHEN @LocationID = -999 THEN PR.LocationID ELSE @LocationID END
		AND PR.CompanyID = CASE WHEN @PropertyID = -999 THEN PR.CompanyID ELSE @PropertyID END
		AND PR.IsApprove =1
		AND PR.StatusID IN(1,4)
		AND PR.ID = CASE WHEN @ID = -999 THEN PR.ID ELSE @ID END

	END


	IF(@Mode = 'S')
	BEGIN

	SELECT PR.ID,PR.LocationID,LO.Name Location,PR.DocumentNo,CONVERT(DATE,PR.InitiatedDate) InitiatedDate,PR.GeneralDescription,PR.EvaluationCriteriaID,EV.EvaluationTemplateName,
		PR.ItemID,PR.ItemName,PR.UnitID,UN.Name Unit,PR.Quantity
		,SU.Name SupplierName,SQ.QuotationFile,SQ.Price,TX.Name TaxGroup,SS.Name StatusName
		,CASE WHEN SQ.StatusID IN( 2,3,4) THEN 1 ELSE 0 END IsSelected,SQ.SupplierID
		FROM ProcurementRequest PR
		INNER JOIN LOCATIONS LO ON PR.LocationID = LO.ID
		INNER JOIN EvaluationTemplate EV ON EV.ID = PR.EvaluationCriteriaID
		INNER JOIN UNITS UN ON UN.ID = PR.UnitID
		INNER JOIN SupplierQuotation SQ ON SQ.ProcurementID = PR.ID
		INNER JOIN Suppliers SU ON SQ.SupplierID = SU.ID
		INNER JOIN TaxGroups TX ON TX.TaxGroupId = SQ.TaxGroupId
		INNER JOIN SupplierQuotationStatus SS ON SS.ID = SQ.StatusID
		WHERE PR.LocationID = CASE WHEN @LocationID = -999 THEN PR.LocationID ELSE @LocationID END
		AND PR.CompanyID = CASE WHEN @PropertyID = -999 THEN PR.CompanyID ELSE @PropertyID END
		AND PR.IsApprove =1
		AND PR.StatusID IN(1,4)
		AND PR.ID = CASE WHEN @ID = -999 THEN PR.ID ELSE @ID END

	END

	IF(@Mode = 'AD')
	BEGIN

	SELECT ProcurementID,SupplierID,SUM(AssignedScore) AssignedScore,SUM(MaxMarks)MaxMarks
	INTO #ProcurementEvaluation
	FROM ProcurementEvaluation
	WHERE ProcurementID = @ID
	GROUP BY ProcurementID,SupplierID



	SELECT PR.ID,PR.LocationID,LO.Name Location,PR.DocumentNo,CONVERT(DATE,PR.InitiatedDate) InitiatedDate,PR.GeneralDescription,PR.EvaluationCriteriaID,EV.EvaluationTemplateName,
		PR.ItemID,PR.ItemName,PR.UnitID,UN.Name Unit,PR.Quantity
		,SU.Name SupplierName,SQ.QuotationFile,SQ.Price,TX.Name TaxGroup,SS.Name StatusName
		,CASE WHEN SQ.StatusID IN(2,3,4) THEN 1 ELSE 0 END IsSelected,SQ.SupplierID,PS.Name ProcurementStatus
		,TP.AssignedScore,TP.MaxMarks
		FROM ProcurementRequest PR
		INNER JOIN LOCATIONS LO ON PR.LocationID = LO.ID
		INNER JOIN EvaluationTemplate EV ON EV.ID = PR.EvaluationCriteriaID
		INNER JOIN UNITS UN ON UN.ID = PR.UnitID
		INNER JOIN SupplierQuotation SQ ON SQ.ProcurementID = PR.ID
		INNER JOIN Suppliers SU ON SQ.SupplierID = SU.ID
		INNER JOIN TaxGroups TX ON TX.TaxGroupId = SQ.TaxGroupId
		INNER JOIN SupplierQuotationStatus SS ON SS.ID = SQ.StatusID
		INNER JOIN ProcurementStatus PS ON PS.ID = PR.StatusID
		INNER JOIN #ProcurementEvaluation TP ON TP.ProcurementID = SQ.ProcurementID AND   SQ.SupplierID = TP.SupplierID
		WHERE PR.LocationID = CASE WHEN @LocationID = -999 THEN PR.LocationID ELSE @LocationID END
		AND PR.CompanyID = CASE WHEN @PropertyID = -999 THEN PR.CompanyID ELSE @PropertyID END
		AND PR.IsApprove =1
		AND PR.StatusID =4
		AND PR.ID = CASE WHEN @ID = -999 THEN PR.ID ELSE @ID END
		ORDER BY AssignedScore DESC

	END

	IF(@Mode = 'AH')
	BEGIN

	SELECT DISTINCT PR.ID,PR.LocationID,LO.Name Location,PR.DocumentNo,CONVERT(DATE,PR.InitiatedDate) InitiatedDate
		FROM ProcurementRequest PR
		INNER JOIN LOCATIONS LO ON PR.LocationID = LO.ID
		INNER JOIN EvaluationTemplate EV ON EV.ID = PR.EvaluationCriteriaID
		INNER JOIN UNITS UN ON UN.ID = PR.UnitID
		INNER JOIN SupplierQuotation SQ ON SQ.ProcurementID = PR.ID
		INNER JOIN Suppliers SU ON SQ.SupplierID = SU.ID
		INNER JOIN TaxGroups TX ON TX.TaxGroupId = SQ.TaxGroupId
		INNER JOIN SupplierQuotationStatus SS ON SS.ID = SQ.StatusID
		INNER JOIN ProcurementStatus PS ON PS.ID = PR.StatusID
		WHERE PR.LocationID = CASE WHEN @LocationID = -999 THEN PR.LocationID ELSE @LocationID END
		AND PR.CompanyID = CASE WHEN @PropertyID = -999 THEN PR.CompanyID ELSE @PropertyID END
		AND PR.IsApprove =1
		AND PR.StatusID =4
		AND PR.ID = CASE WHEN @ID = -999 THEN PR.ID ELSE @ID END

	END



	IF (@Mode = 'PO')
	BEGIN
		SELECT PR.ID,PR.DocumentNo
		FROM ProcurementRequest PR
		WHERE PR.LocationID = CASE WHEN @LocationID = -999 THEN PR.LocationID ELSE @LocationID END
		AND PR.CompanyID = CASE WHEN @PropertyID = -999 THEN PR.CompanyID ELSE @PropertyID END
		AND PR.IsApprove =1
		AND PR.StatusID =2
		AND PR.StockItemHeaderID = @ID

	END
END

GO

