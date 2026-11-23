CREATE PROCEDURE [dbo].[SP_SelectSetMenuSubLevelsByItemCode] 
	@LevelCode VARCHAR(10),
	@SetMenuItemCode VARCHAR(10),
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT l.SetMenuSubLevelID,l.Description,l.IsActive, 
	case 
	when l.IsActive  = 1 then  'Active' 
	when l.IsActive  = 0 then  'Inctive' 
	else 'N/A'
	end  AS LevelStatus
	FROM POS_SetMenuSubLevels l INNER JOIN POS_SetMenuSubLevelDetails s on l.SetMenuSubLevelID = s.SetMenuSubLevelID AND L.PropertyId = S.PropertyId
	where s.SetMenuItemID  = @SetMenuItemCode AND S.SetMenuLevelID = @LevelCode 
		  AND L.IsActive = 1 AND S.IsActive = 1 AND L.PropertyId = @PropertyId AND S.PropertyId = @PropertyId
	GROUP BY L.SetMenuSubLevelID,L.Description,L.IsActive

END

GO

