-- [dbo].[SP_S_DeleteApproval] 1,2,5242,1
CREATE PROCEDURE [dbo].[SP_S_DeleteApproval]
@TrasactionTypeID INT,@ApprovalTypeID INT, @UserID INT = -999, @PropertyId INT = -999, @LocationID INT, @LoggedUserID INT
AS
BEGIN

--SELECT * FROM UserWiseApproveLevels

	DELETE FROM dbo.UserWiseApproveLevels
	WHERE TransactionTypeID=@TrasactionTypeID AND ApproveLevelID=@ApprovalTypeID
	AND UserProfileId = @UserID AND PropertyId = @PropertyId AND LocationId = @LocationID

	IF NOT EXISTS( SELECT * FROM dbo.UserWiseApproveLevels WHERE TransactionTypeID=@TrasactionTypeID AND ApproveLevelID=@ApprovalTypeID
	AND PropertyId = @PropertyId AND LocationId = @LocationID)
	BEGIN

		--Audit trail for TransactionWiseApprovalTypes delete
		DECLARE @DeletingRowId INT

		IF OBJECT_ID('tempdb..#DeletingApprovalTypes') IS NOT NULL
		DROP TABLE #DeletingApprovalTypes

		SELECT Id
		INTO #DeletingApprovalTypes
		FROM dbo.TransactionWiseApprovalTypes
		WHERE TransactionID = @TrasactionTypeID AND ApprovalTypeID = @ApprovalTypeID
		AND PropertyId = @PropertyId AND LocationId = @LocationID

		WHILE EXISTS (SELECT 1 FROM #DeletingApprovalTypes)
		BEGIN
			SELECT TOP (1) @DeletingRowId = Id
			FROM #DeletingApprovalTypes


			EXEC Inventry_AuditTail_WriteToLog 'TransactionWiseApprovalTypes', @DeletingRowId, 'INV', 'UAD', 'D', @LoggedUserID, @PropertyId, '', ''

			DELETE FROM dbo.TransactionWiseApprovalTypes
			WHERE Id = @DeletingRowId

			DELETE FROM #DeletingApprovalTypes
			WHERE Id = @DeletingRowId
		END

		DROP TABLE #DeletingApprovalTypes

	END
END

GO

