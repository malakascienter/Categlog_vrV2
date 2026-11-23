-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-29
-- Description:	Grades the approver can choose on the Supplier Blacklist Approval screen:
--              'X' (keep blacklisted) and the range grades of the submit's evaluation template
-- [dbo].[SP_GetSupplierBlacklistGrades] 1, 1
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetSupplierBlacklistGrades]
	@CompanyId INT,
	@TransactionHeaderID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @EvaluationTemplateID INT;

	SELECT @EvaluationTemplateID = EvaluationTemplateID
	FROM dbo.SupplierEvaluationHeader
	WHERE ID = @TransactionHeaderID
	  AND PropertyID = @CompanyId;

	SELECT G.Grade, G.MarksFrom, G.MarksTo, G.GradeText
	FROM (
		SELECT N'X' AS Grade, NULL AS MarksFrom, NULL AS MarksTo,
			   N'X - Blacklisted' AS GradeText, 1000 AS SortOrder
		UNION ALL
		SELECT R.Grade, R.MarksFrom, R.MarksTo,
			   CONCAT(R.Grade, N' (', R.MarksFrom, N' - ', R.MarksTo, N' %)'), R.MarksFrom
		FROM dbo.EvaluationCriteriaRange R
		WHERE R.EvaluationTemplateID = @EvaluationTemplateID
		  AND R.Grade <> N'X'
	) G
	ORDER BY G.SortOrder DESC;
END

GO

