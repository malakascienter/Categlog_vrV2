
-- =============================================
-- Author:	    Tharuka Sachintha
-- Create date: 2026-10-29
-- Description:	Supplier Blacklist Approval screen
-- [dbo].[SP_GetSupplierBlacklistApprovals] 1, -999, '2026-10-01', '2026-10-31'
-- =============================================

CREATE   PROCEDURE [dbo].[SP_GetSupplierBlacklistApprovals]
	@CompanyId INT,
	@SupplierID INT = NULL,
	@FromDate DATE = NULL,
	@ToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @IsCentralLogin BIT;

	SELECT @IsCentralLogin = IsCentralLogin
	FROM dbo.Companies
	WHERE CompanyID = @CompanyId;

	SET @FromDate = ISNULL(@FromDate, '19000101');
	SET @ToDate = ISNULL(@ToDate, '99991231');

	CREATE TABLE #Users (Id INT, UserName NVARCHAR(300));

	IF (@IsCentralLogin = 1)
		INSERT INTO #Users (Id, UserName) SELECT Id, UserName FROM dbo.CentralUsers;
	ELSE
		INSERT INTO #Users (Id, UserName) SELECT Id, UserName FROM dbo.UserMasters;

	SELECT SEH.ID AS TransactionHeaderID,
		   ISNULL(SEH.DocumentNumber, '') AS DocumentNumber,
		   ISNULL(S.Code, '') AS SupplierCode,
		   ISNULL(S.Name, '') AS SupplierName,
		   SEH.EvaluationTemplateID, --added by isuru 2026-10-29
		   ISNULL(ET.EvaluationTemplateName, '') AS EvaluationTemplateName,
		   CAST(SEH.TotalScore AS DECIMAL(18,2)) AS TotalScore,
		   CAST(SEH.GradePercentage AS DECIMAL(9,2)) AS GradePercentage,
		   SEH.BenchMarkFailedGRNs,
		   ISNULL(SEH.SupplierGrade, '') AS SupplierGrade, --added by isuru 2026-10-29
		   --changed by isuru 2026-10-29: reason built from the company settings (same rules as SP_CalculateSupplierGrade)
		   LTRIM(CONCAT(
				CASE WHEN ISNULL(C.SupplierGradingBlackListPercentage, 0) > 0
						  AND SEH.GradePercentage < C.SupplierGradingBlackListPercentage
					 THEN CONCAT('Grade % ', CAST(SEH.GradePercentage AS DECIMAL(9,2)),
								 ' is below ', CAST(C.SupplierGradingBlackListPercentage AS DECIMAL(9,2)), ' %. ')
					 ELSE '' END,
				CASE WHEN ISNULL(C.BenchMarkFailCount, 0) > 0
						  AND SEH.BenchMarkFailedGRNs >= C.BenchMarkFailCount
					 THEN CONCAT(SEH.BenchMarkFailedGRNs, ' GRN(s) below Bench Marks (limit ',
								 C.BenchMarkFailCount, ').')
					 ELSE '' END)) AS BlackListReason,
		   FORMAT(SEH.CreatedDate, 'yyyy-MM-dd') AS CreatedDate,
		   ISNULL(U.UserName, '') AS CreatedUser
	FROM dbo.SupplierEvaluationHeader SEH
	INNER JOIN dbo.Suppliers S ON S.ID = SEH.SupplierID
	LEFT JOIN dbo.EvaluationTemplate ET ON ET.ID = SEH.EvaluationTemplateID
	LEFT JOIN dbo.Companies C ON C.CompanyID = SEH.PropertyID --added by isuru 2026-10-29
	LEFT JOIN #Users U ON U.Id = SEH.CreatedUserId
	WHERE SEH.PropertyID = @CompanyId
	  AND SEH.IsApproved = 1
	  AND SEH.DocumentStatus = 'P'
	  AND SEH.SupplierGrade = 'X'
	  AND SEH.IsBlackListedApproved = 0
	  AND (ISNULL(@SupplierID, 0) IN (0, -999) OR SEH.SupplierID = @SupplierID)
	  AND CAST(SEH.CreatedDate AS DATE) BETWEEN @FromDate AND @ToDate
	ORDER BY SEH.ID;
END

GO

