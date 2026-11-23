

--[dbo].[EvaluationCriteriaCreateUpdate]  'CREATE',NULL,'[{"EvaluationTemplateID": 1044,"Criteria": "hi","MaxMarks": 45}]'
--[dbo].[EvaluationCriteriaCreateUpdate]  'UPDATE',1044,'[{"EvaluationTemplateID": 1044,"Criteria": "hELL5O","MaxMarks": 55}]'
CREATE PROCEDURE [dbo].[EvaluationCriteriaCreateUpdate]
	(
	@Action VARCHAR(10),
	@EvaluationTemplateID INT,
	@CriteriaList NVARCHAR(MAX) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		--added by isuru 2026-10-27 / 2026-10-28
		--Reason: Criteria, Max Marks, Bench Marks mandatory; Bench Marks <= Max Marks;
		--        criteria name unique per template; template total Max Marks <= 100
		DECLARE @Msg NVARCHAR(400),
				@CriteriaID INT, @TemplateID INT, @Criteria VARCHAR(MAX),
				@MaxMarks INT, @BenchMarks INT, @OtherTotal INT;

		IF @CriteriaList IS NOT NULL
		BEGIN
			-- the UI sends one criteria object per call
			SELECT TOP (1)
				   @CriteriaID = ID,
				   @TemplateID = EvaluationTemplateID,
				   @Criteria   = LTRIM(RTRIM(Criteria)),
				   @MaxMarks   = MaxMarks,
				   @BenchMarks = BenchMarks
			FROM OPENJSON(@CriteriaList)
			WITH(
				ID INT,
				EvaluationTemplateID INT,
				Criteria varchar(MAX),
				MaxMarks int,
				BenchMarks int
			);

			-- the UI does not send EvaluationTemplateID on update, so take it from the row
			IF @Action <> 'CREATE'
				SELECT @TemplateID = EvaluationTemplateID
				FROM [dbo].[EvaluationCriteria]
				WHERE ID = @CriteriaID;

			IF ISNULL(@Criteria, '') = ''
				THROW 50003, 'Criteria is required.', 1;

			IF @MaxMarks IS NULL OR @MaxMarks <= 0
				THROW 50003, 'Max Marks is required and must be greater than 0.', 1;

			IF @BenchMarks IS NULL OR @BenchMarks < 0
				THROW 50003, 'Bench Marks is required and cannot be negative.', 1;

			IF @BenchMarks > @MaxMarks
				THROW 50001, 'Bench Marks cannot be greater than Max Marks.', 1;

			IF EXISTS (SELECT 1
					   FROM [dbo].[EvaluationCriteria]
					   WHERE EvaluationTemplateID = @TemplateID
						 AND LTRIM(RTRIM(Criteria)) = @Criteria
						 AND (@Action = 'CREATE' OR ID <> @CriteriaID))
			BEGIN
				SET @Msg = CONCAT('Criteria "', LEFT(@Criteria, 200), '" already exists in this template.');
				THROW 50004, @Msg, 1;
			END

			SELECT @OtherTotal = ISNULL(SUM(MaxMarks), 0)
			FROM [dbo].[EvaluationCriteria]
			WHERE EvaluationTemplateID = @TemplateID
			  AND (@Action = 'CREATE' OR ID <> @CriteriaID);

			IF @OtherTotal + @MaxMarks > 100
			BEGIN
				SET @Msg = CONCAT('Total Max Marks of the template cannot exceed 100. Other criteria use: ', @OtherTotal,
								  ', remaining: ', CASE WHEN @OtherTotal >= 100 THEN 0 ELSE 100 - @OtherTotal END, '.');
				THROW 50002, @Msg, 1;
			END
		END
		--End

		IF @Action = 'CREATE'
		BEGIN
			IF @CriteriaList IS NOT NULL
			BEGIN
				--changed by isuru 2026-10-28: insert the validated values
				INSERT INTO [dbo].[EvaluationCriteria] (EvaluationTemplateID, Criteria, MaxMarks, BenchMarks)
				VALUES (@TemplateID, @Criteria, @MaxMarks, @BenchMarks)
			END

			-- Return the created template ID
			--SELECT @LastID AS EvaluationTemplateID

			PRINT 'Criteria created successfully'
		END
		ELSE-- IF @Action = 'UPDATE'
		BEGIN
			-- Update the template name if needed (currently commented out in the original SP)

			-- Remove old criteria and insert new ones
			IF @CriteriaList IS NOT NULL
			BEGIN
				--changed by isuru 2026-10-28: update with the validated values
				UPDATE [dbo].[EvaluationCriteria]
				SET
				    Criteria = @Criteria,
				    MaxMarks = @MaxMarks,
				    BenchMarks = @BenchMarks
				WHERE
				    ID = @CriteriaID

				--DELETE FROM [dbo].[EvaluationCriteria]
				--WHERE EvaluationTemplateID = @EvaluationTemplateID

				--INSERT INTO [dbo].[EvaluationCriteria] (EvaluationTemplateID, Criteria, MaxMarks)
				--SELECT @EvaluationTemplateID, Criteria, MaxMarks
				--FROM OPENJSON(@CriteriaList)
				--WITH(
				--	Criteria varchar(MAX),
				--	MaxMarks int
				--)
			END

			PRINT 'Criteria updated successfully'
		END
	END TRY
	BEGIN CATCH
		-- Handle errors here
		PRINT 'An error occurred: ' + ERROR_MESSAGE();
		THROW;
	END CATCH
END

GO

