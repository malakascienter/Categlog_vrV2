
--POS_SetMenuLevelDetails_T_Select 6351
CREATE PROCEDURE [dbo].[SP_SetMenuLevelDetails_T_Select] 
	@MainMenuId INT,
	@PropertyId INT
AS
BEGIN

	SELECT		s.LevelDetailID as LevelDetailId, M.ItemCode AS MainMenuItemId,S.SetMenuLevelID as SetMenuLevelId,
				S.LevelQuantity AS Quantity, S.SortOrder AS Sequence, L.Description AS LevelName ,
				CASE 
				WHEN S.IsOptional = 1 THEN 'Yes'
				ELSE 'No'
				END as Optional,
				CASE 
				WHEN S.IsDependLevel = 1 THEN 'Yes'
				ELSE 'No'
				END as DependLevel,
				CASE 
				WHEN S.IsActive = 1 THEN 'Active'
				ELSE 'Inactive'
				END as Status,
				CASE 
				WHEN s.DependLevelId = 0 THEN 'N/A'
				ELSE s.DependLevelId
				END as DependLevelId,
				s.IsDependLevel as IsDependLevel,
				s.IsOptional as IsOptional,
				S.IsActive,
				s.MaxQuantity
	FROM		POS_SetMenuLevelDetails S
				INNER JOIN POS_SetMenuLevels L ON S.SetMenuLevelID = L.SetMenuLevelID AND S.PropertyId = L.PropertyId
				INNER JOIN MainMenu M ON S.SetMenuItemID = M.ItemCode  AND S.PropertyId = M.PropertyId
	WHERE		M.ID = @MainMenuId  and l.IsActive =1 AND S.PropertyId = @PropertyId AND M.PropertyId = @PropertyId AND M.PropertyId = @PropertyId
	ORDER BY	S.SortOrder
	
	---------------------------------------------------------------------------------------------------

END

GO

