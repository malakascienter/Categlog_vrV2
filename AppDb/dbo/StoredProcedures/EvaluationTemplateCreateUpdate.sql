

CREATE PROCEDURE [dbo].[EvaluationTemplateCreateUpdate] 
	(
	@Action VARCHAR(10),
	@EvaluationTemplateID INT = NULL,
	@EvaluationTemplateName VARCHAR(255) = NULL,
	@CriteriaList NVARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY
		IF @Action = 'CREATE'
		BEGIN
			INSERT INTO [dbo].[EvaluationTemplate] (EvaluationTemplateName)
			VALUES (@EvaluationTemplateName);

			DECLARE @LastID INT = SCOPE_IDENTITY()

			--IF @CriteriaList IS NOT NULL
			--BEGIN
			--	INSERT INTO [dbo].[EvaluationCriteria] (EvaluationTemplateID, Criteria, MaxMarks)
			--	SELECT @LastID, Criteria, MaxMarks
			--	FROM OPENJSON(@CriteriaList)
			--	WITH(
			--		Criteria varchar(MAX),
			--		MaxMarks int
			--	)
			--END

			-- Return the created template ID
			SELECT @LastID AS EvaluationTemplateID
			PRINT 'Template created successfully'
		END

		ELSE-- IF @Action = 'UPDATE'
		BEGIN
			-- Update the template name if needed (currently commented out in the original SP)
			UPDATE [dbo].[EvaluationTemplate]
			SET EvaluationTemplateName = @EvaluationTemplateName
			WHERE ID = @EvaluationTemplateID;

			-- Remove old criteria and insert new ones
			

			--IF @CriteriaList IS NOT NULL
			--BEGIN
			--	DELETE FROM [dbo].[EvaluationCriteria]
			--	WHERE EvaluationTemplateID = @EvaluationTemplateID

			--	INSERT INTO [dbo].[EvaluationCriteria] (EvaluationTemplateID, Criteria, MaxMarks)
			--	SELECT @EvaluationTemplateID, Criteria, MaxMarks
			--	FROM OPENJSON(@CriteriaList)
			--	WITH(
			--		Criteria varchar(MAX),
			--		MaxMarks int
			--	)
			--END

			PRINT 'Template updated successfully'
		END
	END TRY
	BEGIN CATCH
		-- Handle errors here
		PRINT 'An error occurred: ' + ERROR_MESSAGE();
		THROW;
	END CATCH
END

GO

