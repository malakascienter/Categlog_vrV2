-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Update one reminder rule configuration row.
--
--              Edits a single row by its Id, unlike LTY_SaveReminder which
--              replaces a whole reminder's configuration in one go. Both exist
--              because the screens differ: the setup screen posts the complete
--              set, the grid edits one line.
--
--              The rule is re-checked against the reminder on every update.
--              LTY_ReminderRuleConfig carries both ids and LTY_ReminderRule
--              carries its own ReminderId, so an edit that changed only the rule
--              could otherwise leave the row pointing at a rule belonging to a
--              different reminder.
--
--              SendTypeId stays 1, as in LTY_SaveReminder - see the note there.
-- =============================================
-- EXEC [dbo].[LTY_UpdateReminderConfig] @Id = 1, @PropertyId = 1,
--      @ReminderId = 1, @ReminderRuleId = 2, @TemplateId = 18
CREATE   PROCEDURE [dbo].[LTY_UpdateReminderConfig]
	@Id INT,
	@PropertyId INT,
	@ReminderId INT,
	@ReminderRuleId INT,
	@TemplateId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @SendTypeId INT = 1;      -- fixed until a send-type lookup exists

	BEGIN TRY

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_ReminderRuleConfig]
					   WHERE Id = @Id AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('This reminder configuration no longer exists.', 16, 1);
		END

		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_Reminder]
					   WHERE Id = @ReminderId AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('This reminder does not exist.', 16, 1);
		END

		---- The rule has to belong to the reminder ----
		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_ReminderRule] AS rr
					   WHERE rr.Id         = @ReminderRuleId
						 AND rr.PropertyId = @PropertyId
						 AND (rr.ReminderId = @ReminderId OR rr.ReminderId IS NULL))
		BEGIN
			RAISERROR('This rule does not belong to this reminder.', 16, 1);
		END

		---- The same rule cannot be configured twice for one reminder ----
		IF EXISTS (SELECT 1 FROM [dbo].[LTY_ReminderRuleConfig]
				   WHERE ReminderId     = @ReminderId
					 AND ReminderRuleId = @ReminderRuleId
					 AND PropertyId     = @PropertyId
					 AND Id            <> @Id)
		BEGIN
			RAISERROR('This rule is already configured for this reminder.', 16, 1);
		END

		UPDATE [dbo].[LTY_ReminderRuleConfig]
		SET
			ReminderId     = @ReminderId,
			ReminderRuleId = @ReminderRuleId,
			SendTypeId     = @SendTypeId,
			TemplateId     = @TemplateId
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

