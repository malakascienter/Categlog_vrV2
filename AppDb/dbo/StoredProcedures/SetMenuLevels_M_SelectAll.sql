CREATE PROCEDURE [dbo].[SetMenuLevels_M_SelectAll] 
@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT * ,
	case 
	when IsActive  = 1 then  'Active' 
	when IsActive  = 0 then  'Inctive' 
	else 'N/A'
	end  AS LevelStatus
	FROM POS_SetMenuLevels 
	WHERE PropertyId =  @PropertyId
END

GO

