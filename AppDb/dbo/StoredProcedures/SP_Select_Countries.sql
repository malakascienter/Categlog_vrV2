-- =============================================
-- Author:		Isuru Pramodya
-- Create date:	2026-01-27
-- Description:	SP to view Country selecttion
--  [dbo].[SP_Select_Countries] -999

-- =============================================
CREATE   PROCEDURE [dbo].[SP_Select_Countries]
	@ID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT Id,CountryName,ISO2,ISO3
	FROM COUNTRIES WITH (NOLOCK)
	WHERE IsActive = 1
	AND ID = CASE WHEN @ID = -999 THEN ID ELSE @ID END
END

GO

