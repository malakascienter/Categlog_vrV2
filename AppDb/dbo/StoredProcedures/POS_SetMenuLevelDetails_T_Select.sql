--POS_SetMenuLevelDetails_T_Select 2492
CREATE PROCEDURE [dbo].[POS_SetMenuLevelDetails_T_Select] 
	@MainMenuId NVARCHAR(10)
AS
BEGIN
	
	Declare @ItemCode NVARCHAR(10)
	SELECT @ItemCode =  ItemCode FROM MainMenu WHERE Id =  @MainMenuId

	SELECT		S.*, S.LevelQuantity AS Quantity, S.SortOrder AS [Sequence], L.Description AS LevelName , s.ItemCount as ItemQty
	FROM		POS_SetMenuLevelDetails S
	INNER JOIN	POS_SetMenuLevels L ON S.SetMenuLevelID = L.SetMenuLevelID
	WHERE		SetMenuItemID = @ItemCode
END

GO

