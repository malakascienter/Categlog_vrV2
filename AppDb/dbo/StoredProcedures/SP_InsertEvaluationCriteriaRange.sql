-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-06-09
-- Description:	Inserting / Updating Crietera Range

-- [dbo].[SP_InsertEvaluationCriteriaRange] 'UPDATE',4,'{"EvaluationTemplateID":2,"RangeID":0,"MaxMarks":0,"MarksFrom":41,"MarksTo":50,"Grade":"C"}'

-- =============================================
CREATE PROCEDURE [dbo].[SP_InsertEvaluationCriteriaRange]
(@Action VARCHAR(10),
@ID INT,
@CriteriaList NVARCHAR(MAX) = NULL
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;
	SET NOCOUNT ON;

	DECLARE @MaxMarks INT,@EvaluationTemplateID INT,@Grade VARCHAR(MAX),@MarksFrom INT,@MarksTo INT
	--added by isuru 2026-10-28
	DECLARE @NextFrom INT, @OldFrom INT, @OldTo INT, @NextRangeFrom INT, @Msg NVARCHAR(400)

	IF (@Action = 'CREATE')
	BEGIN
		IF @CriteriaList IS NOT NULL
		BEGIN
			SELECT @EvaluationTemplateID = EvaluationTemplateID,
				   @Grade = LTRIM(RTRIM(Grade)),
				   @MarksFrom = MarksFrom,
				   @MarksTo = MarksTo
			FROM OPENJSON(@CriteriaList)
			WITH(EvaluationTemplateID INT,
				MarksFrom INT,
				MarksTo INT,
				Grade VARCHAR(MAX)
				)

			--added by isuru 2026-10-28
			--Reason: ranges 0..100, contiguous - the new range starts right after the last one
			SELECT @NextFrom = ISNULL(MAX(MarksTo) + 1, 0)
			FROM EvaluationCriteriaRange WITH (UPDLOCK, HOLDLOCK)
			WHERE EvaluationTemplateID = @EvaluationTemplateID

			IF ISNULL(@Grade, '') = ''
				THROW 50030, 'Grade is required.', 1;

			IF @NextFrom > 100
				THROW 50031, 'Ranges already cover 0 - 100. No more ranges can be added.', 1;

			IF @MarksFrom IS NULL OR @MarksFrom <> @NextFrom
			BEGIN
				SET @Msg = CASE WHEN @NextFrom = 0 THEN 'The first range must start from 0.'
								ELSE CONCAT('From must be ', @NextFrom, ' (the previous range ends at ', @NextFrom - 1, ').') END;
				THROW 50032, @Msg, 1;
			END

			IF @MarksTo IS NULL OR @MarksTo < @MarksFrom OR @MarksTo > 100
			BEGIN
				SET @Msg = CONCAT('To must be between ', @MarksFrom, ' and 100.');
				THROW 50033, @Msg, 1;
			END
			--End

			IF EXISTS(SELECT 1 FROM EvaluationCriteriaRange WHERE EvaluationTemplateID = @EvaluationTemplateID AND Grade = @Grade)
				THROW 50034, 'Duplicate Grade found for this Template', 1;

			SELECT @MaxMarks =SUM(MAXMARKS)
			FROM EvaluationCriteria
			WHERE EvaluationTemplateID= @EvaluationTemplateID

			INSERT INTO EvaluationCriteriaRange(EvaluationTemplateID, MaxMarks, MarksFrom, MarksTo, Grade, SysDateTime)
			VALUES (@EvaluationTemplateID, @MaxMarks, @MarksFrom, @MarksTo, @Grade, GETDATE())
		END
	END

	IF(@Action = 'DELETE')
	BEGIN
		SELECT @EvaluationTemplateID = EvaluationTemplateID, @OldFrom = MarksFrom
		FROM EvaluationCriteriaRange
		WHERE ID = @ID

		IF @EvaluationTemplateID IS NULL
			THROW 50035, 'No Range Found', 1;

		--added by isuru 2026-10-28
		--Reason: grade ranges of a template already used in Supplier Grading cannot be deleted
		IF EXISTS(SELECT 1 FROM SupplierEvaluationHeader WHERE EvaluationTemplateID = @EvaluationTemplateID)
			THROW 50038, 'This template is used in Supplier Grading. Its ranges cannot be deleted.', 1;

		--added by isuru 2026-10-28
		--Reason: deleting a middle range would leave a gap
		IF EXISTS(SELECT 1 FROM EvaluationCriteriaRange WHERE EvaluationTemplateID = @EvaluationTemplateID AND MarksFrom > @OldFrom)
			THROW 50036, 'Only the last range can be deleted (deleting this range would leave a gap).', 1;

		DELETE FROM EvaluationCriteriaRange WHERE ID = @ID
	END

	IF(@Action= 'UPDATE')
	BEGIN
		SELECT @EvaluationTemplateID = EvaluationTemplateID, @OldFrom = MarksFrom, @OldTo = MarksTo
		FROM EvaluationCriteriaRange
		WHERE ID = @ID

		IF @EvaluationTemplateID IS NULL
			THROW 50035, 'No Range Found', 1;

		SELECT @MarksTo = MarksTo, @Grade = LTRIM(RTRIM(Grade))
		FROM OPENJSON(@CriteriaList)
		WITH(
			MarksTo INT,
			Grade VARCHAR(MAX)
			)

		--added by isuru 2026-10-28
		--Reason: From never changes; To only on the last range; ranges stay inside 0..100
		IF ISNULL(@Grade, '') = ''
			THROW 50030, 'Grade is required.', 1;

		IF EXISTS(SELECT 1 FROM EvaluationCriteriaRange WHERE EvaluationTemplateID = @EvaluationTemplateID AND Grade = @Grade AND ID <> @ID)
			THROW 50034, 'Duplicate Grade found for this Template', 1;

		SELECT @NextRangeFrom = MIN(MarksFrom)
		FROM EvaluationCriteriaRange
		WHERE EvaluationTemplateID = @EvaluationTemplateID AND MarksFrom > @OldFrom

		IF @NextRangeFrom IS NOT NULL AND ISNULL(@MarksTo, -1) <> @OldTo
		BEGIN
			SET @Msg = CONCAT('To can be changed only on the last range (the next range starts at ', @NextRangeFrom, ').');
			THROW 50037, @Msg, 1;
		END

		IF @MarksTo IS NULL OR @MarksTo < @OldFrom OR @MarksTo > 100
		BEGIN
			SET @Msg = CONCAT('To must be between ', @OldFrom, ' and 100.');
			THROW 50033, @Msg, 1;
		END
		--End

		UPDATE EvaluationCriteriaRange
		SET MarksTo = @MarksTo,
			Grade = @Grade,
			UpdateDateTime = getdate()
		WHERE ID = @ID
	END

        COMMIT TRAN; -- Transaction Success!
    END TRY
 	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		THROW;
	END CATCH
END;

GO

