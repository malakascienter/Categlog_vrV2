
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevel_T_Delete] 
	@SubLevelId	INT,
	@PropertyId INT
AS
BEGIN
	
	UPDATE POS_SetMenuSubLevels SET IsActive = 0
	WHERE SetMenuSubLevelID = @SubLevelId AND PropertyId = @PropertyId

END

GO

