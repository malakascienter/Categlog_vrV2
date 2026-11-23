
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevelDetails_T_Select] 
	@MainMenuId INT,
	@PropertyId INT
AS
BEGIN

	SELECT		s.SubLevelDetailID, M.ID AS SetMenuItemID,S.SetMenuLevelID,S.SetMenuSubLevelID,S.SortOrder,S.SubLevelQuantity, 
				S.IsActive AS IsActive,l.Description as LevelName,sl.Description as SubLevelName,
				CASE WHEN S.IsActive = 1 THEN 'Active' ELSE 'Inactive' END as Status
	FROM		POS_SetMenuSubLevelDetails S
				INNER JOIN POS_SetMenuLevelDetails x on S.SetMenuLevelID = x.SetMenuLevelID and s.SetMenuItemID = x.SetMenuItemID AND X.PropertyId = S.PropertyId
				INNER JOIN POS_SetMenuLevels L ON S.SetMenuLevelID = L.SetMenuLevelID AND L.PropertyId = S.PropertyId
				INNER JOIN POS_SetMenuSubLevels sl on s.SetMenuSubLevelID = sl.SetMenuSubLevelId AND SL.PropertyId = S.PropertyId
				INNER JOIN MainMenu M ON S.SetMenuItemID = M.ItemCode AND M.PropertyId = S.PropertyId
	WHERE		M.ID = @MainMenuId AND   M.Active = 1 AND L.IsActive = 1 AND SL.IsActive = 1  AND x.IsActive = 1 AND M.PropertyId = @PropertyId 
	AND S.PropertyId = @PropertyId AND X.PropertyId = @PropertyId AND L.PropertyId = @PropertyId AND sl.PropertyId = @PropertyId
	ORDER BY	S.SortOrder
	
	---------------------------------------------------------------------------------------------------

END

GO

