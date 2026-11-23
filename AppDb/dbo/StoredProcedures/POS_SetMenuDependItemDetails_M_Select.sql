

CREATE PROCEDURE [dbo].[POS_SetMenuDependItemDetails_M_Select] 
	@LevelCode varchar(10),
	@ItemCode varchar(10),
	@PropertyId INT
AS  
BEGIN  


  SELECT [LevelItemID]
      ,[SetMenuItemID]
      ,[SetMenuLevelID]
	  ,[SetMenuSubLevelId]
      ,[MenuItemID]
      ,[SortOrder]
      ,[AddRate]
  FROM [dbo].[POS_SetMenuItemDetails]
  WHERE [SetMenuLevelID] = @LevelCode and [SetMenuItemID] = @ItemCode and IsActive = 1 AND PropertyId = @PropertyId
END

GO

