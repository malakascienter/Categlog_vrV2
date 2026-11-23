
--POS_SetMenuLevelDetails_T_Select 6351
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevelDetails_T_SelectByID] 
	@LevelDetailID INT,
	@PropertyId INT
AS
BEGIN

	SELECT [SubLevelDetailID]
      ,[SetMenuItemID]
      ,[SetMenuLevelID]
      ,[SetMenuSubLevelID]
      ,[SortOrder]
      ,[SubLevelQuantity]
      ,[IsActive]
  FROM [dbo].[POS_SetMenuSubLevelDetails]
				
	WHERE		SubLevelDetailID = @LevelDetailID  AND PropertyId = @PropertyId

	
	---------------------------------------------------------------------------------------------------

END

GO

