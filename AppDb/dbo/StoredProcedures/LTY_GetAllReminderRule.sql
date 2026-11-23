-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Rules belonging to a reminder.
--
--              @ReminderId is the point of the call, but it is nullable: passing
--              NULL returns every rule in the property, which is what an admin
--              grid listing all rules with their reminder wants. The API sends
--              it, so the normal path is one reminder's rules.
--
--              ReminderName comes along so the caller does not have to join back
--              to LTY_Reminder just to label a grid.
-- =============================================
-- EXEC [dbo].[LTY_GetAllReminderRule] @ReminderId = 1, @PropertyId = 1
CREATE   PROCEDURE [dbo].[LTY_GetAllReminderRule]
	@ReminderId INT = NULL,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT
			rr.Id,
			rr.Name,
			rr.ReminderId,
			ReminderName = rem.Name,
			rr.PropertyId
		FROM [dbo].[LTY_ReminderRule] AS rr
		LEFT JOIN [dbo].[LTY_Reminder] AS rem
			ON rem.Id         = rr.ReminderId
		   AND rem.PropertyId = rr.PropertyId
		WHERE rr.PropertyId = @PropertyId
		  AND (@ReminderId IS NULL OR rr.ReminderId = @ReminderId)
		ORDER BY rr.ReminderId, rr.Id;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

