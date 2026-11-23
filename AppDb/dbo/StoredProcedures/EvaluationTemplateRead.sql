

--[dbo].[EvaluationTemplateRead] 'READ',5,NULL,'[{ "Criteria": "Price", "MaxMarks": 35 },{ "Criteria": "Trust", "MaxMarks": 5 }]'
CREATE PROCEDURE [dbo].[EvaluationTemplateRead] 

AS
BEGIN
	SET NOCOUNT ON;
	BEGIN
		SELECT * FROM [dbo].[EvaluationTemplate]


		PRINT 'Template Read Successfully';
	END
END

GO

