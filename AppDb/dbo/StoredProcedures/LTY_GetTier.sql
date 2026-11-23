-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-05
-- Description:	Get Single Tier by PropertyId and TierId
--
--              2026-08-17: IsTierAutoUpgrade added to the select list.
--
--              2026-08-17: the WHERE clause filtered on PropertyId only, so this
--              returned every tier in the property and the caller took whichever row
--              came back first. @TierId is now applied.
-- =============================================
-- EXEC [dbo].[LTY_GetTier] @PropertyId = 1, @TierId = 4
CREATE   PROCEDURE [dbo].[LTY_GetTier]
	@PropertyId INT,
	@TierId INT
AS
BEGIN
	SET NOCOUNT ON;

		SELECT
			TierId,
			TierName,
			PropertyId,
			MiniumPoint,
			MaxiumPoint,
			RuleId,
			SortOrder,
			IsActive,
			IsTierAutoUpgrade,
			CreatedBy,
			CreatedDate,
			ModifyId,
			ModifyDate
		FROM [dbo].[LTY_Tier]
		WHERE PropertyId = @PropertyId
		  AND TierId     = @TierId;
END

GO

