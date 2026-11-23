

CREATE PROCEDURE [dbo].[EvaluationCriteriaDelete] 
	(
	@Action VARCHAR(10),
	@EvaluationCriteriaID INT = NULL
	--@EvaluationTemplateName VARCHAR(255) = NULL,
	--@CriteriaList NVARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	IF @Action = 'DELETE'
	BEGIN
		DELETE FROM [dbo].[EvaluationCriteria]
		WHERE ID = @EvaluationCriteriaID
		
		PRINT 'Criteria Deleted Successfully';
	END
END

GO

