-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-28
-- Description:	Supplier Grading approval with optional mark changes by the approver

-- [dbo].[SP_ApproveSupplierGrading] 1, 9212, 3, '[{"StockTransactionHeaderID":8435,"ApproverRemarks":"checked","CriteriaList":[{"CriteriaID":13,"Score":8}]}]', NULL

-- =============================================
CREATE PROCEDURE [dbo].[SP_ApproveSupplierGrading]
	@CompanyId INT,
	@UserProfileId INT,
	@TransactionHeaderID INT,
	@JSONDetails NVARCHAR(MAX) = NULL,
	@RowsAffected INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	SET @RowsAffected = 0;

	DECLARE @SGRId INT, @Msg NVARCHAR(400);
	--added by isuru 2026-10-29: submitted values before the approver's changes
	DECLARE @OldTotalScore DECIMAL(18,2), @OldSupplierGrade NVARCHAR(10),
			@OldGradePercentage DECIMAL(9,2), @OldBenchMarkFailedGRNs INT;

	BEGIN TRY
		BEGIN TRANSACTION;

		SELECT @SGRId = Id FROM dbo.TransactionTypes WHERE Code = 'SGR';

		IF NOT EXISTS (SELECT 1 FROM dbo.ApprovalLogs
					   WHERE TransactionID = @SGRId
						 AND TransactionHeaderID = @TransactionHeaderID
						 AND PropertyID = @CompanyId
						 AND ApprovalUserID = @UserProfileId
						 AND IsComplete = 0)
			THROW 50010, 'This Supplier Grading is not waiting for your approval.', 1;

		CREATE TABLE #Rows (StockTransactionHeaderID INT, ApproverRemarks VARCHAR(250));
		CREATE TABLE #Scores (StockTransactionHeaderID INT, CriteriaID INT, Score DECIMAL(18,2));

		IF (@JSONDetails IS NOT NULL AND LTRIM(RTRIM(@JSONDetails)) <> '')
		BEGIN
			INSERT INTO #Rows (StockTransactionHeaderID, ApproverRemarks)
			SELECT StockTransactionHeaderID, LTRIM(RTRIM(ISNULL(ApproverRemarks, '')))
			FROM OPENJSON(@JSONDetails)
			WITH (StockTransactionHeaderID INT, ApproverRemarks VARCHAR(250));

			INSERT INTO #Scores (StockTransactionHeaderID, CriteriaID, Score)
			SELECT R.StockTransactionHeaderID, C.CriteriaID, C.Score
			FROM OPENJSON(@JSONDetails)
			WITH (StockTransactionHeaderID INT, CriteriaList NVARCHAR(MAX) AS JSON) AS R
			CROSS APPLY OPENJSON(R.CriteriaList)
			WITH (CriteriaID INT, Score DECIMAL(18,2)) AS C;
		END

		-- marks 0 .. MaxMarks
		IF EXISTS (SELECT 1
				   FROM #Scores S
				   INNER JOIN dbo.SupplierEvaluationDetail D
					 ON D.EvaluationHeaderID = @TransactionHeaderID
					AND D.StockTransactionHeaderID = S.StockTransactionHeaderID
					AND D.CriteriaID = S.CriteriaID
				   WHERE S.Score IS NULL OR S.Score < 0 OR S.Score > D.MaxMarks)
			THROW 50011, 'Marks must be between 0 and the criteria Max Marks.', 1;

		-- a document row with a changed mark needs an approver remark
		SELECT TOP (1) @Msg = CONCAT('Approver remark is required for ', SH.DocumentNo, ' because its marks were changed.')
		FROM #Scores S
		INNER JOIN dbo.SupplierEvaluationDetail D
		  ON D.EvaluationHeaderID = @TransactionHeaderID
		 AND D.StockTransactionHeaderID = S.StockTransactionHeaderID
		 AND D.CriteriaID = S.CriteriaID
		INNER JOIN dbo.StockTransactionHeaders SH WITH (NOLOCK) ON SH.Id = S.StockTransactionHeaderID
		WHERE S.Score <> D.Score
		  AND NOT EXISTS (SELECT 1 FROM #Rows R
						  WHERE R.StockTransactionHeaderID = S.StockTransactionHeaderID
							AND R.ApproverRemarks <> '');

		IF @Msg IS NOT NULL
			THROW 50012, @Msg, 1;

		-- changed marks (the submitted mark is kept in OriginalScore the first time)
		UPDATE D
		SET OriginalScore = ISNULL(D.OriginalScore, D.Score),
			Score = S.Score,
			ApproverUserID = @UserProfileId,
			ApproverModifiedDate = GETDATE()
		FROM dbo.SupplierEvaluationDetail D
		INNER JOIN #Scores S
		  ON D.EvaluationHeaderID = @TransactionHeaderID
		 AND D.StockTransactionHeaderID = S.StockTransactionHeaderID
		 AND D.CriteriaID = S.CriteriaID
		WHERE S.Score <> D.Score;

		-- approver remarks
		UPDATE D
		SET ApproverRemarks = R.ApproverRemarks
		FROM dbo.SupplierEvaluationDetail D
		INNER JOIN #Rows R
		  ON D.EvaluationHeaderID = @TransactionHeaderID
		 AND D.StockTransactionHeaderID = R.StockTransactionHeaderID
		WHERE R.ApproverRemarks <> '';

		--added by isuru 2026-10-29: keep the submitted values to compare after the recalculation
		SELECT @OldTotalScore = TotalScore,
			   @OldSupplierGrade = SupplierGrade,
			   @OldGradePercentage = GradePercentage,
			   @OldBenchMarkFailedGRNs = BenchMarkFailedGRNs
		FROM dbo.SupplierEvaluationHeader
		WHERE ID = @TransactionHeaderID;

		UPDATE dbo.SupplierEvaluationHeader
		SET TotalScore = (SELECT SUM(CASE WHEN D.TxnType = 'M' THEN -D.Score ELSE D.Score END) --changed by isuru 2026-10-29: net GRN - SRN, same as the submit
						  FROM dbo.SupplierEvaluationDetail D
						  WHERE D.EvaluationHeaderID = @TransactionHeaderID)
		WHERE ID = @TransactionHeaderID;

		--added by isuru 2026-10-28: grade / blacklist again with the approver's marks
		EXEC dbo.SP_CalculateSupplierGrade @TransactionHeaderID;

		--added by isuru 2026-10-29
		--Reason: the approver's marks changed TotalScore / grade / % / bench fails ->
		--        keep the submitted values in the Original* columns (only the first time)
		UPDATE dbo.SupplierEvaluationHeader
		SET OriginalTotalScore = @OldTotalScore,
			OriginalSupplierGrade = @OldSupplierGrade,
			OriginalGradePercentage = @OldGradePercentage,
			OriginalBenchMarkFailedGRNs = @OldBenchMarkFailedGRNs
		WHERE ID = @TransactionHeaderID
		  AND OriginalTotalScore IS NULL AND OriginalSupplierGrade IS NULL
		  AND OriginalGradePercentage IS NULL AND OriginalBenchMarkFailedGRNs IS NULL
		  AND EXISTS (SELECT TotalScore, SupplierGrade, GradePercentage, BenchMarkFailedGRNs
					  EXCEPT
					  SELECT @OldTotalScore, @OldSupplierGrade, @OldGradePercentage, @OldBenchMarkFailedGRNs);
		--End

		-- approval level (same as the SGR branch of SP_Update_CommonTransactionApproval):
		-- any one user of the level approves it for all users of that level
		UPDATE dbo.ApprovalLogs
		SET DocStatus = 'C', IsComplete = 1, ApprovalDate = GETDATE(),
			LastModUserID = @UserProfileId, LastModDate = GETDATE()
		WHERE TransactionID = @SGRId
		  AND TransactionHeaderID = @TransactionHeaderID
		  AND PropertyID = @CompanyId
		  AND IsComplete = 0
		  AND SeqID IN (SELECT AL.SeqID FROM dbo.ApprovalLogs AL
						WHERE AL.TransactionID = @SGRId
						  AND AL.TransactionHeaderID = @TransactionHeaderID
						  AND AL.PropertyID = @CompanyId
						  AND AL.ApprovalUserID = @UserProfileId
						  AND AL.IsComplete = 0);

		SET @RowsAffected = @@ROWCOUNT;

		IF NOT EXISTS (SELECT 1 FROM dbo.ApprovalLogs
					   WHERE TransactionID = @SGRId
						 AND TransactionHeaderID = @TransactionHeaderID
						 AND PropertyID = @CompanyId
						 AND IsComplete = 0)
		BEGIN
			UPDATE dbo.SupplierEvaluationHeader
			SET IsApproved = 1,
				DocumentStatus = CASE WHEN SupplierGrade = 'X' THEN 'P' ELSE 'C' END --changed by isuru 2026-10-29: grade X stays 'P' for the blacklist approval
			WHERE ID = @TransactionHeaderID;
		END

		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		IF @@TRANCOUNT > 0
			ROLLBACK TRANSACTION;
		SET @RowsAffected = 0;
		THROW;
	END CATCH
END

GO

