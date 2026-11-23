-- =============================================
-- Author:		Ravindu
-- Create date: 2026-08-04
-- Description:	Get All Point Earning Base Values by PropertyId
-- =============================================
CREATE   PROCEDURE [dbo].[LTY_GetAllPointEarningBaseValue]
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

		SELECT
			[Id],
			[Name]
		FROM [dbo].[LTY_PointEarningBaseValue]
		WHERE PropertyId = @PropertyId
		  AND IsActive   = 1
		ORDER BY [Name];


END

GO

