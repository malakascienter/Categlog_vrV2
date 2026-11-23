-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	One reminder rule configuration row, by its own Id.
--
--              Same columns as LTY_GetAllReminderConfig so the edit form and the
--              grid read the same shape.
-- =============================================
-- EXEC [dbo].[LTY_GetReminderConfigById] @Id = 1, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_GetReminderConfigById]
	@Id INT,
	@PropertyId INT
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
		WHERE c.Id         = @Id
		  AND c.PropertyId = @PropertyId;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

