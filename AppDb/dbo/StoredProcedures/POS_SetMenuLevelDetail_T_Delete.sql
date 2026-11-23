Create PROCEDURE [dbo].[POS_SetMenuLevelDetail_T_Delete] 
	@LevelDetailID	 INT
AS
BEGIN

	DECLARE @SetMenuId NVARCHAR(10), @LevelId NVARCHAR(10)

	SELECT @SetMenuId = SetMenuItemID, @LevelId = SetMenuLevelID FROM POS_SetMenuLevelDetails WHERE LevelDetailID = @LevelDetailID

	DELETE 
	FROM	POS_SetMenuLevelDetails 
	WHERE	LevelDetailID = @LevelDetailID

	DELETE 
	FROM	POS_SetMenuItemDetails
	WHERE	SetMenuItemID = @SetMenuId AND SetMenuLevelID = @LevelId

	

END

GO

