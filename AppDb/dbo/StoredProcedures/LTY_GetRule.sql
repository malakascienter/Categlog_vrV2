-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get Single Rule by PropertyId and RuleId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetRule]
	@PropertyId INT,
	@RuleId INT
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
		  AND RuleId     = @RuleId;
END

GO

