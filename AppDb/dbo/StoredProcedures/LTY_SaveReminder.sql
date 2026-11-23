-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Save a reminder's rule configuration.
--
--              The payload is the COMPLETE state for the reminder, so the
--              existing rows are replaced wholesale - the same way
--              LTY_SavePromotion treats a promotion's child sets. An empty array
--              clears the configuration.
--
--              SendTypeId is written as 1. It is a column on the table with no
--              lookup behind it yet and nothing in the payload, so it is set
--              here rather than left null - see the note at the foot of this
--              file before adding a send-type screen.
--
--              Every ReminderRuleId is checked to belong to @ReminderId.
--              LTY_ReminderRuleConfig carries both ids and LTY_ReminderRule now
--              carries its own ReminderId, so without this a config row could
--              say reminder 1 while pointing at a rule owned by reminder 3, and
--              nothing downstream would know which to believe.
-- =============================================
-- EXEC [dbo].[LTY_SaveReminder] @ReminderId = 1, @PropertyId = 1,
--      @ReminderRulesJson = N'[{"ReminderRuleId":1,"TemplateId":17},
--                              {"ReminderRuleId":2,"TemplateId":18}]'
CREATE   PROCEDURE [dbo].[LTY_SaveReminder]
	@ReminderId INT,
	@PropertyId INT,
	@ReminderRulesJson NVARCHAR(MAX) = N'[]'
AS
BEGIN
	SET NOCOUNT ON;
	SET XACT_ABORT ON;

	DECLARE @SendTypeId INT = 1;      -- fixed until a send-type lookup exists
	DECLARE @BadRule    INT;

	BEGIN TRY

		BEGIN TRANSACTION;

		IF NOT EXISTS (SELECT 1 FROM [dbo].[LTY_Reminder]
					   WHERE Id = @ReminderId AND PropertyId = @PropertyId)
		BEGIN
			RAISERROR('This reminder does not exist.', 16, 1);
		END

		---- The rules being configured ----
		CREATE TABLE #Rule
		(
			ReminderRuleId INT NOT NULL PRIMARY KEY,
			TemplateId     INT NULL
		);

		INSERT INTO #Rule (ReminderRuleId, TemplateId)
		SELECT DISTINCT r.ReminderRuleId, r.TemplateId
		FROM OPENJSON(@ReminderRulesJson)
		WITH (
			ReminderRuleId INT '$.ReminderRuleId',
			TemplateId     INT '$.TemplateId'
		) AS r
		WHERE r.ReminderRuleId IS NOT NULL;

		---- A rule must belong to the reminder being saved ----
		SELECT TOP (1) @BadRule = x.ReminderRuleId
		FROM #Rule AS x
		WHERE NOT EXISTS (SELECT 1 FROM [dbo].[LTY_ReminderRule] AS rr
						  WHERE rr.Id         = x.ReminderRuleId
							AND rr.PropertyId = @PropertyId
							AND (rr.ReminderId = @ReminderId OR rr.ReminderId IS NULL));

		IF (@BadRule IS NOT NULL)
		BEGIN
			DECLARE @Msg NVARCHAR(200) =
				CONCAT('Rule ', @BadRule, ' does not belong to this reminder.');
			RAISERROR(@Msg, 16, 1);
		END

		---- Replaced wholesale: the payload is the complete state ----
		DELETE FROM [dbo].[LTY_ReminderRuleConfig]
		WHERE ReminderId = @ReminderId AND PropertyId = @PropertyId;

		INSERT INTO [dbo].[LTY_ReminderRuleConfig]
			(ReminderId, ReminderRuleId, SendTypeId, TemplateId, PropertyId)
		SELECT @ReminderId, x.ReminderRuleId, @SendTypeId, x.TemplateId, @PropertyId
		FROM #Rule AS x;

		COMMIT TRANSACTION;

		SELECT @ReminderId AS ReminderId, @@ROWCOUNT AS RuleCount;

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

