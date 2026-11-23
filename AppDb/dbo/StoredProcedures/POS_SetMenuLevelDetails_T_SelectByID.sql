
--POS_SetMenuLevelDetails_T_Select 6351
CREATE PROCEDURE [dbo].[POS_SetMenuLevelDetails_T_SelectByID] 
	@LevelDetailID INT,
	@PropertyId INT
AS
BEGIN

	SELECT		s.LevelDetailID as LevelDetailId,s.SetMenuItemID as MainMenuItemId,
	s.SetMenuLevelID as SetMenuLevelId,s.SortOrder as Sequence ,s.LevelQuantity as Quantity,s.MaxQuantity,
	s.IsDependLevel as IsDependLevel,s.DependLevelId as DependLevelId,s.IsOptional as IsOptional ,s.IsActive, s.ItemCount as ItemQty
	FROM		POS_SetMenuLevelDetails s
				
	WHERE		LevelDetailID = @LevelDetailID AND PropertyId = @PropertyId

	
	---------------------------------------------------------------------------------------------------

END

GO

