-- =============================================
-- Author:		Chamathka Sooriyapala
-- Create date: 2021-04-23
-- Description:	Get non combo main menu items
-- =============================================
CREATE PROCEDURE [dbo].[Select_Non_Combo_Menu] 
	@MenuCode	VARCHAR(20),
	@PropertyId	INT
AS
BEGIN
	SELECT  * 
	FROM MainMenu 
	WHERE IsCombo = 0  AND PropertyId = @PropertyId
END

GO

