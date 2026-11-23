
CREATE PROCEDURE [dbo].[SP_SetMenuLevel_Delete]
(
	@SetMenuLevelId VARCHAR(4)
)
AS
BEGIN	
	SET NOCOUNT ON;
	IF EXISTS (SELECT 1 FROM POS_SetMenuLevels WHERE SetMenuLevelId = @SetMenuLevelId)
	BEGIN
		DELETE FROM POS_SetMenuLevels WHERE SetMenuLevelId = @SetMenuLevelId 
	END
	ELSE
	BEGIN
		RAISERROR('No record exists.',16,1)
	END	


END

GO

