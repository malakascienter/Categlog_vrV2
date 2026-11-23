-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get All Active Rule Types by PropertyId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllRuleType]
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;


		SELECT
			[Id],
			[Name]
		FROM [dbo].[LTY_RuleType]
		WHERE PropertyId = @PropertyId
		  AND IsActive   = 1

END

GO

