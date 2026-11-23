-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Delete one reminder rule configuration row.
--
--              A hard delete: LTY_ReminderRuleConfig has no IsActive or
--              IsDeleted column to set. It is a join between a reminder, a rule
--              and a template - removing it means "this rule is no longer part
--              of this reminder", and nothing else refers to the row by id.
--
--              The reminder, the rule and the template all stay. Only the link
--              between them goes.
-- =============================================
-- EXEC [dbo].[LTY_DeleteReminderConfig] @Id = 1, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_DeleteReminderConfig]
	@Id INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_ReminderRuleConfig]
					   WHERE Id = @Id AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('This reminder configuration no longer exists.', 16, 1);
		END

		DELETE FROM [dbo].[LTY_ReminderRuleConfig]
		WHERE Id         = @Id
		  AND PropertyId = @PropertyId;

		COMMIT TRANSACTION;

		SELECT @Id AS Id;

	END TRY
	BEGIN CATCH

		IF XACT_STATE() <> 0
			ROLLBACK TRANSACTION;

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

