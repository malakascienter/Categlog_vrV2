

CREATE  PROCEDURE [dbo].[SP_POS_SetMenuDependItemDetails_M_Select] 
	@MainItemCode	nvarchar(50),
	@LevelCode	nvarchar(50),
	@LevelItemId	nvarchar(50),
	@PropertyId INT
AS  
BEGIN  
	SELECT [DependItemDetailsID]
      ,[MainItemCode]
      ,[LevelCode]
      ,[LevelItemId]
      ,[DepenItemId]
      ,[Price]
      ,[IsActive]
      ,[CreatedUser]
      ,[CreatedDate]
      ,[ModifiedUser]
      ,[ModifiedDate]
  FROM [dbo].[POS_SetMenuDependItemDetails] D 
	WHERE D.MainItemCode = @MainItemCode AND D.LevelCode = @LevelCode AND D.LevelItemId = @LevelItemId AND IsActive = 1 and d.Propertyid  = @PropertyId
END

GO

