

--[dbo].[EvaluationTemplateCRUD] 'DELETE',5,NULL,'[{ "Criteria": "Price", "MaxMarks": 35 },{ "Criteria": "Trust", "MaxMarks": 5 }]'
CREATE PROCEDURE [dbo].[EvaluationTemplateDelete] 
	(
	@Action VARCHAR(10),
	@EvaluationTemplateID INT = NULL
	--@EvaluationTemplateName VARCHAR(255) = NULL,
	--@CriteriaList NVARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	IF @Action = 'DELETE'
	BEGIN
		BEGIN TRY --added by isuru 2026-10-28
			BEGIN TRANSACTION;

			--added by isuru 2026-10-28
			--Reason: a template used in Supplier Grading cannot be deleted
			IF EXISTS (SELECT 1 FROM dbo.SupplierEvaluationHeader WHERE EvaluationTemplateID = @EvaluationTemplateID)
			   OR EXISTS (SELECT 1 FROM dbo.Suppliers WHERE EvaluationTemplateID = @EvaluationTemplateID)
				THROW 50040, 'This template is used in Supplier Grading and cannot be deleted.', 1;

			--added by isuru 2026-10-28: grade ranges go with the template (were left behind before)
			DELETE FROM [dbo].[EvaluationCriteriaRange]
			WHERE EvaluationTemplateID = @EvaluationTemplateID

			DELETE FROM [dbo].[EvaluationCriteria]
			WHERE EvaluationTemplateID = @EvaluationTemplateID

			DELETE FROM [dbo].[EvaluationTemplate]
			WHERE ID = @EvaluationTemplateID

			COMMIT TRANSACTION;
			PRINT 'Template Deleted Successfully';
		END TRY
		BEGIN CATCH
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
			THROW;
		END CATCH
	END
END

GO

