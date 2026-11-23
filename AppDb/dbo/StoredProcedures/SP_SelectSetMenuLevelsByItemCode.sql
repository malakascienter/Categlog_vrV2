CREATE PROCEDURE [dbo].[SP_SelectSetMenuLevelsByItemCode] 

	@SetMenuItemId VARCHAR(10),
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT l.SetMenuLevelID,l.Description,l.IsActive, 
	case 
	when l.IsActive  = 1 then  'Active' 
	when l.IsActive  = 0 then  'Inctive' 
	else 'N/A'
	end  AS LevelStatus
	FROM POS_SetMenuLevels l INNER JOIN POS_SetMenuLevelDetails s on l.SetMenuLevelID = s.SetMenuLevelID AND L.PropertyId = S.PropertyId
	where s.SetMenuItemID  = @SetMenuItemId AND L.IsActive = 1 AND S.IsActive = 1 AND L.PropertyId = @PropertyId AND S.PropertyId = @PropertyId
	GROUP BY L.SetMenuLevelID,L.Description,L.IsActive

END

--Use Form - Level BreakDown/Sub Level BreakDown / Item BreakDown

GO

