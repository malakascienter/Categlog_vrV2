-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-06-09
-- Description:	Loading Evaluation Crieteria Range
--  [dbo].[SP_SelectEvaluationCriteriaRange] 2
-- =============================================
create PROCEDURE [dbo].[SP_SelectEvaluationCriteriaRange](
	@EvaluationTemplateID INT
)
AS
BEGIN
	SET NOCOUNT ON;

	SELECT ER.EvaluationTemplateID,ER.ID RangeID,
	SUM(EC.MaxMarks) MaxMarks,
	ER.MarksFrom,ER.MarksTo,ER.Grade
	FROM EvaluationTemplate ET 
	INNER JOIN  EvaluationCriteriaRange ER ON ER.EvaluationTemplateID = ET.ID
	INNER JOIN EvaluationCriteria EC ON EC.EvaluationTemplateID = ET.ID
	WHERE ET.ID = @EvaluationTemplateID
	GROUP BY ER.EvaluationTemplateID,ER.ID,ER.MarksFrom,ER.MarksTo,ER.Grade
	ORDER BY ER.MarksFrom asc

    
END

GO

