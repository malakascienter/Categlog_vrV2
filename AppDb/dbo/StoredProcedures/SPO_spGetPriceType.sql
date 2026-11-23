
-- =============================================
-- Author:		Dilshan
-- Create date: 2025-10-14
-- Description:	SpeacialOrderRevamp
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_spGetPriceType]
	@PropertyId INT
AS
BEGIN

	SET NOCOUNT ON;

	SELECT *
	FROM POS_MainMenuPriceTypes

    
END

GO

