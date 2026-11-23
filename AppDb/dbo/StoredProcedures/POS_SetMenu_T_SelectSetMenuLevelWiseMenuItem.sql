--POS_SetMenu_T_SelectSetMenuLevelWiseMenuItem 2492, 3
CREATE PROCEDURE [dbo].[POS_SetMenu_T_SelectSetMenuLevelWiseMenuItem] 
	@SetMenuItemId		INT,
	@SetMenuLevelId		INT
AS
BEGIN

	Declare @ItemCode NVARCHAR(10)
	Declare @LevelCode NVARCHAR(10)

	SELECT @LevelCode = SetMenuLevelID FROM POS_SetMenuLevelDetails WHERE LevelDetailID = @SetMenuLevelId
	SELECT @ItemCode =  ItemCode FROM MainMenu WHERE Id =  @SetMenuItemId

	SELECT PS.*, PS.SortOrder AS [Sequence], M.Description AS MenuItemName
	FROM POS_SetMenuItemDetails PS
	INNER JOIN MainMenu M ON M.ItemCode = PS.MenuItemID
	WHERE SetMenuItemID = @ItemCode AND SetMenuLevelID = @LevelCode
END

GO

