-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get All Rules by PropertyId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllRule]
	@PropertyId INT,
	@IsActive BIT = NULL          -- NULL = no filter, 1 = active only, 0 = inactive only
AS
BEGIN
	SET NOCOUNT ON;

		SELECT
			RuleId,
			RuleName,
			Description,
			PropertyId,
			RuleTypeId,
			Rate,
			BaseValueId,
			Multiplier,
			IsActive,
			CreateBy,
			CreatedDate,
			ModifyBy,
			ModifyDate,
			ExpireDayCount
		FROM [dbo].[LTY_PointEarningRule]
		WHERE PropertyId = @PropertyId
		  AND (@IsActive IS NULL OR IsActive = @IsActive)
		ORDER BY RuleId DESC;
END

GO

