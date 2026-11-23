-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Reminder rule configuration rows from LTY_ReminderRuleConfig.
--
--              One row per configuration, keyed on its own Id - this is the
--              grid, and Id is what GetById, Update and Delete act on.
--
--              @ReminderId narrows it to one reminder's configuration; leave it
--              off for every row in the property.
--
--              The reminder, rule and template names come along so the grid
--              needs no second call. LEFT JOINs throughout: a config whose
--              template was deleted still has to appear, with a blank name,
--              rather than dropping out of the list unexplained.
-- =============================================
-- EXEC [dbo].[LTY_GetAllReminderConfig] @PropertyId = 1
-- EXEC [dbo].[LTY_GetAllReminderConfig] @PropertyId = 1, @ReminderId = 1
CREATE   PROCEDURE [dbo].[LTY_GetAllReminderConfig]
	@PropertyId INT,
	@ReminderId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT
			c.Id,
			c.ReminderId,
			ReminderName     = rem.Name,
			c.ReminderRuleId,
			ReminderRuleName = rr.Name,
			c.SendTypeId,
			c.TemplateId,
			TemplateName     = t.Name,
			c.PropertyId
		FROM [dbo].[LTY_ReminderRuleConfig] AS c
		LEFT JOIN [dbo].[LTY_Reminder] AS rem
			ON rem.Id         = c.ReminderId
		   AND rem.PropertyId = c.PropertyId
		LEFT JOIN [dbo].[LTY_ReminderRule] AS rr
			ON rr.Id         = c.ReminderRuleId
		   AND rr.PropertyId = c.PropertyId
		LEFT JOIN [dbo].[LTYC_Template] AS t
			ON t.TemplateId = c.TemplateId
		   AND t.PropertyId = c.PropertyId
		WHERE c.PropertyId = @PropertyId
		  AND (@ReminderId IS NULL OR c.ReminderId = @ReminderId)
		ORDER BY c.ReminderId, c.Id;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

