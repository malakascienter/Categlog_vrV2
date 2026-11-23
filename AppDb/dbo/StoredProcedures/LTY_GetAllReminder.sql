-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-18
-- Description:	Get All Active Reminders by PropertyId.
--
--              Shaped like its sibling LTY_GetAllRuleType, with one difference:
--              @IsActive is a parameter rather than a hardcoded 1. It DEFAULTS
--              to 1, so a plain call returns the active reminders the dropdown
--              wants, and passing NULL returns every row for an admin grid that
--              needs to show and re-activate the inactive ones.
-- =============================================
-- EXEC [dbo].[LTY_GetAllReminder] @PropertyId = 1
-- EXEC [dbo].[LTY_GetAllReminder] @PropertyId = 1, @IsActive = NULL
CREATE   PROCEDURE [dbo].[LTY_GetAllReminder]
	@PropertyId INT,
	@IsActive BIT = 1          -- 1 active (default), 0 inactive, NULL all
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		SELECT
			r.Id,
			r.Name,
			r.IsActive,
			r.PropertyId
		FROM [dbo].[LTY_Reminder] AS r
		WHERE r.PropertyId = @PropertyId
		  AND (@IsActive IS NULL OR r.IsActive = @IsActive)
		ORDER BY r.Name;

	END TRY
	BEGIN CATCH

		DECLARE @ErrMsg   NVARCHAR(4000) = ERROR_MESSAGE();
		DECLARE @ErrSev   INT            = ERROR_SEVERITY();
		DECLARE @ErrState INT            = ERROR_STATE();

		RAISERROR(@ErrMsg, @ErrSev, @ErrState);

	END CATCH
END

GO

