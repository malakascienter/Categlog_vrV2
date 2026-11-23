

--[dbo].[EvaluationCriteriaRead] 1044
CREATE PROCEDURE [dbo].[EvaluationCriteriaRead] (
	@EvaluationTemplateID INT
)

AS
BEGIN
	SET NOCOUNT ON;
	BEGIN
		SELECT * FROM [dbo].[EvaluationCriteria]
		WHERE EvaluationTemplateID = @EvaluationTemplateID


		PRINT 'Criteria Read Successfully';
	END
END

GO

