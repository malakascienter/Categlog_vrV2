-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-28
-- Description:	Supplier grade / blacklist of one Supplier Grading submit
--   Grade %  = (sum of GRN document marks - sum of SRN document marks)
--              / number of GRNs / document Max Marks * 100   (never below 0)
--   Blacklisted (SupplierGrade 'X', IsBlackListedApproved 0) when
--     a) Grade % < Companies.SupplierGradingBlackListPercentage   (NULL/0 = off), or
--     b) GRNs with at least one mark below the criteria Bench Marks
--        >= Companies.BenchMarkFailCount                          (NULL/0 = off)
--   otherwise SupplierGrade = Grade of the template range that contains
--   FLOOR(Grade %), IsBlackListedApproved NULL.
--   No GRN in the submit -> no grade (all values NULL).
-- [dbo].[SP_CalculateSupplierGrade] 1
-- =============================================
CREATE PROCEDURE [dbo].[SP_CalculateSupplierGrade]
	@EvaluationHeaderID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PropertyID INT, @TemplateID INT,
			@BlackListPercentage DECIMAL(9,2), @BenchMarkFailCount INT,
			@GRNCount INT, @NetMarks DECIMAL(18,2), @DocumentMaxMarks DECIMAL(18,2),
			@GradePercentage DECIMAL(9,2), @FailedGRNs INT, @Grade NVARCHAR(10), @IsBlackListed BIT;

	SELECT @PropertyID = PropertyID, @TemplateID = EvaluationTemplateID
	FROM dbo.SupplierEvaluationHeader
	WHERE ID = @EvaluationHeaderID;

	IF @PropertyID IS NULL
		RETURN;

	SELECT @BlackListPercentage = SupplierGradingBlackListPercentage,
		   @BenchMarkFailCount = BenchMarkFailCount
	FROM dbo.Companies
	WHERE CompanyID = @PropertyID;

	;WITH Docs AS (
		SELECT D.StockTransactionHeaderID,
			   -- 2026-10-28: TxnType P = GRN (plus), M = SRN (minus)
			   MAX(COALESCE(D.TxnType, CASE WHEN SH.TransactionType = 'SR' THEN 'M' ELSE 'P' END)) AS TxnType,
			   SUM(D.Score) AS DocMarks,
			   SUM(D.MaxMarks) AS DocMaxMarks,
			   -- 2026-10-28: bench as stored on the detail row (criteria bench at submit)
			   MAX(CASE WHEN COALESCE(D.BenchMarks, EC.BenchMarks) IS NOT NULL
						 AND D.Score < COALESCE(D.BenchMarks, EC.BenchMarks) THEN 1 ELSE 0 END) AS BelowBench
		FROM dbo.SupplierEvaluationDetail D
		INNER JOIN dbo.StockTransactionHeaders SH WITH (NOLOCK) ON SH.Id = D.StockTransactionHeaderID
		LEFT JOIN dbo.EvaluationCriteria EC ON EC.ID = D.CriteriaID
		WHERE D.EvaluationHeaderID = @EvaluationHeaderID
		GROUP BY D.StockTransactionHeaderID
	)
	SELECT @GRNCount = SUM(CASE WHEN TxnType = 'M' THEN 0 ELSE 1 END),
		   @NetMarks = SUM(CASE WHEN TxnType = 'M' THEN -DocMarks ELSE DocMarks END),
		   @DocumentMaxMarks = MAX(CASE WHEN TxnType = 'M' THEN NULL ELSE DocMaxMarks END),
		   @FailedGRNs = SUM(CASE WHEN TxnType <> 'M' AND BelowBench = 1 THEN 1 ELSE 0 END)
	FROM Docs;

	--added by isuru 2026-10-28: TotalScore = GRN marks - SRN marks (never below 0)
	UPDATE dbo.SupplierEvaluationHeader
	SET TotalScore = CASE WHEN ISNULL(@NetMarks, 0) < 0 THEN 0 ELSE ISNULL(@NetMarks, 0) END
	WHERE ID = @EvaluationHeaderID;

	IF ISNULL(@GRNCount, 0) = 0 OR ISNULL(@DocumentMaxMarks, 0) = 0
	BEGIN
		-- no GRN (only Supplier Returns) -> no grade
		UPDATE dbo.SupplierEvaluationHeader
		SET SupplierGrade = NULL,
			IsBlackListedApproved = NULL,
			GradePercentage = NULL,
			BenchMarkFailedGRNs = NULL
		WHERE ID = @EvaluationHeaderID;
		RETURN;
	END

	SET @GradePercentage = @NetMarks / @GRNCount / @DocumentMaxMarks * 100;
	IF @GradePercentage < 0
		SET @GradePercentage = 0;

	IF (ISNULL(@BlackListPercentage, 0) > 0 AND @GradePercentage < @BlackListPercentage)
	   OR (ISNULL(@BenchMarkFailCount, 0) > 0 AND @FailedGRNs >= @BenchMarkFailCount)
	BEGIN
		SET @Grade = 'X';
		SET @IsBlackListed = 1;
	END
	ELSE
	BEGIN
		SELECT TOP (1) @Grade = Grade
		FROM dbo.EvaluationCriteriaRange
		WHERE EvaluationTemplateID = @TemplateID
		  AND FLOOR(@GradePercentage) BETWEEN MarksFrom AND MarksTo
		ORDER BY MarksFrom;
		SET @IsBlackListed = 0;
	END

	UPDATE dbo.SupplierEvaluationHeader
	SET SupplierGrade = @Grade,
		-- blacklisted: 0 = waiting for blacklist approval (an approved 1 is kept on a recalculation)
		IsBlackListedApproved = CASE WHEN @IsBlackListed = 1 THEN ISNULL(IsBlackListedApproved, 0) ELSE NULL END,
		GradePercentage = @GradePercentage,
		BenchMarkFailedGRNs = @FailedGRNs
	WHERE ID = @EvaluationHeaderID;
END

GO

