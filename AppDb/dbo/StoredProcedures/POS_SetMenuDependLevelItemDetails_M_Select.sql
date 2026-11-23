
--POS_SetMenuDependLevelItemDetails_M_Select
CREATE  PROCEDURE [dbo].[POS_SetMenuDependLevelItemDetails_M_Select] 
	@LevelCode varchar(10),
	@ItemCode varchar(10),
	@LevelItemCode varchar(10),
	@PropertyId INT
AS  
BEGIN  
	SELECT P.[DependItemDetailsID]
      ,P.[MainItemCode]
      ,P.[LevelCode]
      ,P.[LevelItemId]
      ,P.[DepenItemId]
      ,P.[Price]
      ,P.[IsActive]
      ,P.[CreatedUser]
      ,P.[CreatedDate]
      ,P.[ModifiedUser]
      ,P.[ModifiedDate]
  FROM [dbo].[POS_SetMenuDependItemDetails] P INNER JOIN POS_SetMenuItemDetails S ON P.MainItemCode = S.SetMenuItemID AND P.PropertyId = S.PropertyId
  AND P.LevelCode = S.SetMenuLevelID AND P.LevelItemId = s.MenuItemID
  WHERE P.LevelCode = @LevelCode and P.MainItemCode = @ItemCode and P.LevelItemId = @LevelItemCode and P.IsActive = 1 AND S.IsActive = 1 AND P.Propertyid = @PropertyId and S.Propertyid = @PropertyId
END

GO

