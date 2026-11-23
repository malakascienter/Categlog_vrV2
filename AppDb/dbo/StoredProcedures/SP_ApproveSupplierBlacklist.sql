-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-10-29
-- Description:	Supplier Blacklist approval of a blacklisted Supplier Grading submit,
--              with an optional grade change by the approver (remark required when changed)
-- [dbo].[SP_ApproveSupplierBlacklist] 1, 9212, 1, 'B', 'supplier improved', NULL, NULL
-- =============================================
CREATE  PROCEDURE [dbo].[SP_ApproveSupplierBlacklist]
	@CompanyId INT,
	@UserProfileId INT,
	@TransactionHeaderID INT,
	@SupplierGrade NVARCHAR(10) = NULL,     -- NULL / '' = keep the current grade ('X')
	@Remarks NVARCHAR(500) = NULL,
	@RowsAffected INT = NULL OUTPUT,
	@FinalGrade NVARCHAR(10) = NULL OUTPUT  -- grade after the approval
AS
BEGIN
	SET NOCOUNT ON;
	SET @RowsAffected = 0;
	SET @FinalGrade = NULL;

	DECLARE @CurrentGrade NVARCHAR(10), @EvaluationTemplateID INT;

	SET @SupplierGrade = NULLIF(LTRIM(RTRIM(@SupplierGrade)), N'');
	SET @Remarks = NULLIF(LTRIM(RTRIM(@Remarks)), N'');

	SELECT @CurrentGrade = SupplierGrade,
		   @EvaluationTemplateID = EvaluationTemplateID
	FROM dbo.SupplierEvaluationHeader
	WHERE ID = @TransactionHeaderID
	  AND PropertyID = @CompanyId
	  AND IsApproved = 1
	  AND DocumentStatus = 'P'
	  AND SupplierGrade = 'X'
	  AND IsBlackListedApproved = 0;

	IF @CurrentGrade IS NULL
		THROW 50020, 'This Supplier Grading is not waiting for the blacklist approval.', 1;

	SET @SupplierGrade = ISNULL(@SupplierGrade, @CurrentGrade);

	IF @SupplierGrade <> N'X'
	   AND NOT EXISTS (SELECT 1 FROM dbo.EvaluationCriteriaRange
					   WHERE EvaluationTemplateID = @EvaluationTemplateID
						 AND Grade = @SupplierGrade)
		THROW 50021, 'The selected grade is not a grade of the evaluation template ranges.', 1;

	IF @SupplierGrade <> @CurrentGrade AND @Remarks IS NULL
		THROW 50022, 'A remark is required when the grade is changed.', 1;

	UPDATE dbo.SupplierEvaluationHeader
	SET BlackListOriginalGrade = SupplierGrade,
		SupplierGrade = @SupplierGrade,
		IsBlackListedApproved = 1,
		DocumentStatus = 'C',
		BlackListApprovedUserID = @UserProfileId,
		BlackListApprovedDate = GETDATE(),
		BlackListApprovedRemarks = @Remarks
	WHERE ID = @TransactionHeaderID
	  AND PropertyID = @CompanyId
	  AND IsBlackListedApproved = 0;

	SET @RowsAffected = @@ROWCOUNT;
	SET @FinalGrade = @SupplierGrade;
END

GO

