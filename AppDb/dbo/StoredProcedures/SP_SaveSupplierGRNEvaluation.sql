-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-06-03
-- Description:	Inserting Supplier Grading
-- [dbo].[SP_SaveSupplierGRNEvaluation]  '[{"HeaderID":2029,"IsEvaluated":false,"Remarks":"KLKL","SupplierID":1,"PropertyID":1,"LocationID":1,"EvaluationTemplateID":3,"UserID":4168,"CriteriaList":[{"CriteriaID":4,"Criteria":"First Mark","MaxMarks":80,"Score":45},{"CriteriaID":5,"Criteria":"Second mark","MaxMarks":70,"Score":50},{"CriteriaID":6,"Criteria":"Thirf Mark","MaxMarks":50,"Score":35}]},{"HeaderID":2034,"IsEvaluated":false,"Remarks":"HHHJ","SupplierID":1,"PropertyID":1,"LocationID":14,"EvaluationTemplateID":3,"UserID":4168,"CriteriaList":[{"CriteriaID":4,"Criteria":"First Mark","MaxMarks":80,"Score":56},{"CriteriaID":5,"Criteria":"Second mark","MaxMarks":70,"Score":46},{"CriteriaID":6,"Criteria":"Thirf Mark","MaxMarks":50,"Score":12}]}]'

-- =============================================
CREATE PROCEDURE [dbo].[SP_SaveSupplierGRNEvaluation]  
@JSONDetails NVARCHAR(MAX),
@NewHeaderID INT = NULL OUTPUT,             --added by isuru 2026-10-28: ID of the new SupplierEvaluationHeader
@DocumentNumber NVARCHAR(40) = NULL OUTPUT  --added by isuru 2026-10-28: its document number SGR/000001
AS
BEGIN
		SET NOCOUNT ON;
BEGIN TRY
BEGIN TRANSACTION

		IF OBJECT_ID('tempdb..#SupplierGrading') IS NOT NULL
		DROP TABLE #SupplierGrading

		IF OBJECT_ID('tempdb..#Criteria') IS NOT NULL
		DROP TABLE #Criteria

		DECLARE @PropertyID INT,  @UserID INT,  @headerid INT,@EvaluationTemplateID INT,@SupplierID INT,@TotalMarks DECIMAL(18,6),
		@SupEvaluationTemplateID VARCHAR(MAX)

		--added by isuru 2026-10-28: document number (@DocumentNumber is the OUTPUT parameter)
		DECLARE @NextNumber VARCHAR(30), @Prefix NVARCHAR(10)
		--added by isuru 2026-10-28: approval workflow
		DECLARE @IsApproved BIT, @SGRTransactionID INT
		SELECT @NewHeaderID = NULL, @DocumentNumber = NULL

		CREATE TABLE #SupplierGrading
		(
		HeaderID INT,
		IsEvaluated BIT,
		Remarks NVARCHAR(MAX),
		SupplierID INT,
		PropertyID INT,
		LocationID INT,
		EvaluationTemplateID INT,
		UserID INT
		);

		CREATE TABLE #Criteria
		(
		HeaderID INT,
		CriteriaID INT,
		Criteria NVARCHAR(MAX),
		MaxMarks INT,
		Score INT
		);

		INSERT INTO #SupplierGrading (HeaderID, IsEvaluated, Remarks, SupplierID, PropertyID, LocationID, EvaluationTemplateID, UserID)
		SELECT
		JSONData.HeaderID,
		JSONData.IsEvaluated,
		JSONData.Remarks,
		JSONData.SupplierID,
		JSONData.PropertyID,
		JSONData.LocationID,
		JSONData.EvaluationTemplateID,
		JSONData.UserID
		FROM OPENJSON(@JSONDetails)
		WITH (
		HeaderID INT,
		IsEvaluated BIT,
		Remarks NVARCHAR(MAX),
		SupplierID INT,
		PropertyID INT,
		LocationID INT,
		EvaluationTemplateID INT,
		UserID INT,
		CriteriaList NVARCHAR(MAX) AS JSON
		) AS JSONData;

		INSERT INTO #Criteria (HeaderID, CriteriaID, Criteria, MaxMarks, Score)
		SELECT
		parent.HeaderID,
		child.CriteriaID,
		child.Criteria,
		child.MaxMarks,
		child.Score
		FROM OPENJSON(@JSONDetails)
		WITH (
		HeaderID INT,
		CriteriaList NVARCHAR(MAX) AS JSON
		) AS parent
		CROSS APPLY OPENJSON(parent.CriteriaList)
		WITH (
		CriteriaID INT,
		Criteria NVARCHAR(MAX),
		MaxMarks INT,
		Score INT
		) AS child;



		SELECT TOP (1) @SupplierID = SupplierID,@EvaluationTemplateID = EvaluationTemplateID,@UserID = UserID,@PropertyID = PropertyID
		FROM #SupplierGrading

		SELECT @TotalMarks =  SUM(Score)
		FROM #Criteria

		--added by isuru 2026-10-28
		--Reason: approval workflow like Tour Guide. Approval set for Supplier Grading in
		--        Transaction wise approvals (company level, location -999) -> IsApproved = 0,
		--        DocumentStatus 'P' and approval levels are created; no approval set ->
		--        IsApproved = 1, DocumentStatus 'C'.
		SELECT @SGRTransactionID = Id
		FROM dbo.TransactionTypes
		WHERE Code = 'SGR';

		IF EXISTS(SELECT 1 FROM TransactionWiseApprovalTypes WHERE TransactionID = @SGRTransactionID AND PropertyID = @PropertyID)
			SET @IsApproved = 0
		ELSE
			SET @IsApproved = 1
		--End

		--added by isuru 2026-10-28
		--Reason: document number per submit, SGR/000001 (one counter per company, LocationID 0)
		--        counter key 'SG': TransactionTypeWiseNextNumbers.TransactionType is NVARCHAR(2);
		--        the 'SGR' prefix comes from TransactionTypes.Code
		SET @NextNumber = dbo.FN_GetNextDocumentNumber(@PropertyID, 0, 'SG');

		IF (@NextNumber IS NULL)
		BEGIN
			INSERT INTO TransactionTypeWiseNextNumbers (PropertyID, LocationID, TransactionType, NextNumber, LengthOfFormatting)
			VALUES (@PropertyID, 0, 'SG', 1, 6);

			SET @NextNumber = dbo.FN_GetNextDocumentNumber(@PropertyID, 0, 'SG');
		END

		SELECT @Prefix = Code
		FROM dbo.TransactionTypes
		WHERE Code = 'SGR';

		SET @DocumentNumber = ISNULL(@Prefix, 'SGR') + '/' + @NextNumber;

		UPDATE TransactionTypeWiseNextNumbers
		SET NextNumber = NextNumber + 1
		WHERE PropertyID = @PropertyID
		  AND LocationID = 0
		  AND TransactionType = 'SG';
		--End

		INSERT INTO SupplierEvaluationHeader(PropertyID, SupplierID, EvaluationTemplateID, TotalScore, CreatedUserId, CreatedDate,
			DocumentNumber, IsApproved, DocumentStatus) --added by isuru 2026-10-28
		SELECT @PropertyID,@SupplierID,@EvaluationTemplateID,@TotalMarks,@UserID,GETDATE(),
			@DocumentNumber, @IsApproved, CASE WHEN @IsApproved = 1 THEN 'C' ELSE 'P' END --changed by isuru 2026-10-28 (approval)

		SET @headerid = SCOPE_IDENTITY();



		--changed by isuru 2026-10-28: + BenchMarks (criteria bench at submit), TransactionType GRN/SRN, TxnType P/M
		INSERT INTO SupplierEvaluationDetail(EvaluationHeaderID, StockTransactionHeaderID, CriteriaID, MaxMarks, Score, Remarks,
			BenchMarks, TransactionType, TxnType,
			TransactionDate) --added by isuru 2026-10-30: date of the GRN / SRN
		SELECT @headerid,SU.HeaderID,CU.CriteriaID,CU.MaxMarks,CU.Score,SU.Remarks,
			EC.BenchMarks,
			CASE WHEN SH.TransactionType = 'SR' THEN 'SRN' ELSE 'GRN' END,
			CASE WHEN SH.TransactionType = 'SR' THEN 'M' ELSE 'P' END,
			SH.TransactionDate --added by isuru 2026-10-30
		FROM #SupplierGrading SU
		INNER JOIN #Criteria CU ON SU.HeaderID = CU.HeaderID
		LEFT JOIN dbo.EvaluationCriteria EC ON EC.ID = CU.CriteriaID
		LEFT JOIN dbo.StockTransactionHeaders SH WITH (NOLOCK) ON SH.Id = SU.HeaderID


		IF  EXISTS(SELECT 1 FROM SUPPLIERS SU INNER JOIN EvaluationTemplate ET ON SU.EvaluationTemplateID = ET.ID
		WHERE SU.ID = @SupplierID   AND ISNULL(EvaluationTemplateID,0) <> @EvaluationTemplateID)
		BEGIN
			SELECT @SupEvaluationTemplateID =  ET.EvaluationTemplateName
			FROM Suppliers SU
			 INNER JOIN EvaluationTemplate ET ON SU.EvaluationTemplateID = ET.ID
			WHERE SU.ID = @SupplierID

			RAISERROR('Selected Supplier needs to be evaluated with %s', 16, 1, @SupEvaluationTemplateID);
			ROLLBACK TRANSACTION;
			RETURN;

		END
		ELSE
		BEGIN
		UPDATE Suppliers
		SET EvaluationTemplateID = @EvaluationTemplateID
		WHERE ID = @SupplierID
		END

		--added by isuru 2026-10-28
		--Reason: supplier grade / blacklist of the submit (SP_CalculateSupplierGrade)
		EXEC dbo.SP_CalculateSupplierGrade @headerid

		--added by isuru 2026-10-29: no approval set (approved on submit) and grade X ->
		--        DocumentStatus stays 'P' for the blacklist approval
		UPDATE SupplierEvaluationHeader
		SET DocumentStatus = 'P'
		WHERE ID = @headerid
		AND IsApproved = 1
		AND SupplierGrade = 'X'
		--End

		--added by isuru 2026-10-28
		--Reason: approval levels for the new submit (company level, location -999 like Tour Guide)
		IF (@IsApproved = 0)
		BEGIN
			EXEC SP_InsertApprovalLevelForRequest @PropertyID, -999, @SGRTransactionID, @headerid
		END
		--End

COMMIT TRANSACTION

		--added by isuru 2026-10-28: new header ID back to the caller (@DocumentNumber is already set)
		SET @NewHeaderID = @headerid
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
	ROLLBACK TRANSACTION
		SELECT @NewHeaderID = NULL, @DocumentNumber = NULL --added by isuru 2026-10-28: nothing was saved
		DECLARE @ErrorMessage NVARCHAR(4000);
		DECLARE @ErrorSeverity INT;
		DECLARE @ErrorState INT;

		SELECT
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
END

GO

