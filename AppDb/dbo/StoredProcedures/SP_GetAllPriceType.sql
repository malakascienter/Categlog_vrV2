CREATE PROCEDURE [dbo].[SP_GetAllPriceType] 
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * 
	FROM POS_MainMenuPriceTypes
	WHERE IsActive = 1
END

GO

