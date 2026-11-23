CREATE PROCEDURE [dbo].[POS_SetMenuLevelDetails_T_Save] 
	@LevelDetailId	INT,
	@SetMenuItemId	NVARCHAR(10),
	@SetMenuLevelId	NVARCHAR(10),
	@SortOrder		INT,
	@LevelQuantity	INT,
	@MaxQuantity    INT,
	@ItemQty INT
AS
BEGIN
	
	Declare @ItemCode NVARCHAR(10)
	SELECT @ItemCode =  ItemCode FROM MainMenu WHERE Id =  @SetMenuItemId

	IF @LevelDetailId = 0
	BEGIN

		INSERT INTO POS_SetMenuLevelDetails([SetMenuItemID], [SetMenuLevelID], [SortOrder], [LevelQuantity],MaxQuantity,ItemCount)
		VALUES(@ItemCode, @SetMenuLevelId, @SortOrder, @LevelQuantity,@MaxQuantity,isnull(@ItemQty,0))

	END
	ELSE
	BEGIN
		
	   UPDATE [dbo].[POS_SetMenuLevelDetails]
	   SET [SetMenuItemID] = @ItemCode
      ,[SetMenuLevelID] = @SetMenuLevelId
      ,[SortOrder] = @SortOrder
      ,[LevelQuantity] = @LevelQuantity
      ,[SetMenuSubLevelID] = 0
      ,[MaxQuantity] = @MaxQuantity
	  ,ItemCount = isnull(@ItemQty,0)
	   WHERE LevelDetailID = @LevelDetailId

	END

END

GO

