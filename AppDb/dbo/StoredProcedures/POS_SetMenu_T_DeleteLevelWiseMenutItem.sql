Create PROCEDURE [dbo].[POS_SetMenu_T_DeleteLevelWiseMenutItem] 
	@LevelItemId	INT
AS
BEGIN

	DECLARE @SetMenuId NVARCHAR(10)

	SELECT @SetMenuId = SetMenuItemID FROM POS_SetMenuItemDetails WHERE LevelItemID = @LevelItemId
	
	DELETE FROM POS_SetMenuItemDetails WHERE LevelItemID = @LevelItemId

	

END

GO

