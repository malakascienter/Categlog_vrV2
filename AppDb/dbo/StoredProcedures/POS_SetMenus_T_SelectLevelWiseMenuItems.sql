CREATE PROCEDURE [dbo].[POS_SetMenus_T_SelectLevelWiseMenuItems] 
@PropertyId INT
AS
BEGIN
	SELECT	Id, ItemCode ,Description 
	FROM	MainMenu 
	WHERE	IsMainPage = 0 AND IsCombo = 0 AND IsModifier = 0 AND PropertyId = @PropertyId
	ORDER BY Description ASC
END

GO

