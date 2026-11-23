CREATE PROCEDURE [dbo].[POS_SetMenu_T_SaveSetMenuLevelWiseMenuItem] 
	@SetMenuItemId	INT,
	@SetMenuLevelId INT, 
	@MenuItemId		INT, 
	@Sequence		INT, 
	@AddRate		DECIMAL(18,2)
AS
BEGIN

	Declare @ItemCode NVARCHAR(10)
	Declare @MenuItemCode NVARCHAR(10)
	Declare @LevelCode NVARCHAR(10)


	SELECT @LevelCode = SetMenuLevelID FROM POS_SetMenuLevelDetails WHERE LevelDetailID = @SetMenuLevelId
	SELECT @ItemCode =  ItemCode FROM MainMenu WHERE Id =  @SetMenuItemId	
	SELECT @MenuItemCode =  ItemCode FROM MainMenu WHERE Id =  @MenuItemId

	INSERT INTO [POS_SetMenuItemDetails]([SetMenuItemID], [SetMenuLevelID], [MenuItemID], [SortOrder], [AddRate])
	VALUES (@ItemCode, @LevelCode, @MenuItemCode, @Sequence, @AddRate)

	
END

GO

