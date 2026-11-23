-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-28
-- Description:	Evaluation templates usable in Supplier Grading: criteria present and
--              grade ranges covering 0 - 100 (first From 0, next From = previous To + 1,
--              last To 100)
-- [dbo].[SP_GetEvaluationTemplatesForGrading]
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetEvaluationTemplatesForGrading]
AS
BEGIN
	SET NOCOUNT ON;

	;WITH R AS (
		SELECT EvaluationTemplateID, MarksFrom, MarksTo,
			   LAG(MarksTo) OVER (PARTITION BY EvaluationTemplateID ORDER BY MarksFrom, ID) AS PrevTo
		FROM dbo.EvaluationCriteriaRange
	),
	Bad AS (
		SELECT DISTINCT EvaluationTemplateID
		FROM R
		WHERE (PrevTo IS NULL AND MarksFrom <> 0)
		   OR (PrevTo IS NOT NULL AND MarksFrom <> PrevTo + 1)
		   OR MarksTo < MarksFrom
		   OR MarksTo > 100
	),
	Complete AS (
		SELECT EvaluationTemplateID
		FROM dbo.EvaluationCriteriaRange
		GROUP BY EvaluationTemplateID
		HAVING MIN(MarksFrom) = 0 AND MAX(MarksTo) = 100
	)
	SELECT ET.ID, ET.EvaluationTemplateName
	FROM dbo.EvaluationTemplate ET
	INNER JOIN Complete C ON C.EvaluationTemplateID = ET.ID
	WHERE NOT EXISTS (SELECT 1 FROM Bad B WHERE B.EvaluationTemplateID = ET.ID)
	  AND EXISTS (SELECT 1 FROM dbo.EvaluationCriteria EC WHERE EC.EvaluationTemplateID = ET.ID)
	ORDER BY ET.EvaluationTemplateName;
END

GO

