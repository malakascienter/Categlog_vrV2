-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get All Tiers by PropertyId, optional IsActive filter
--
--              2026-08-17: IsTierAutoUpgrade added to the select list. It was being
--              saved but never returned, so the grid and the edit form could not see it.
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllTier]
	@PropertyId INT,
	@IsActive BIT = NULL          -- NULL = no filter, 1 = active only, 0 = inactive only
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
		  AND (@IsActive IS NULL OR IsActive = @IsActive)
		ORDER BY SortOrder, TierId;
END

GO

