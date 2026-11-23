CREATE PROCEDURE [dbo].[SetMenuSubLevels_M_SelectAll] 
@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	

	SELECT SetMenuSubLevelID,Description,IsActive, 
	case 
	when IsActive  = 1 then  'Active' 
	when IsActive  = 0 then  'Inctive' 
	else 'N/A'
	end  AS LevelStatus
	FROM POS_SetMenuSubLevels
	WHERE PropertyId = @PropertyId
	
END

GO

