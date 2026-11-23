
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevel_Save] 
	@SubLevelCode	nvarchar(10),
	@SubLevelName	nvarchar(50),
	@IsActive	bit,
	@PropertyId INT
AS
BEGIN

		
	IF EXISTS(SELECT 1 FROM POS_SetMenuSubLevels WHERE SetMenuSubLevelID = @SubLevelCode AND PropertyId = @PropertyId )
	BEGIN
		RAISERROR('This sub level for set menu is already added', 16, 1)
	END
	ELSE
	BEGIN
		
		INSERT INTO POS_SetMenuSubLevels(SetMenuSubLevelID, Description,IsActive,PropertyId)
		VALUES(@SubLevelCode, @SubLevelName,@IsActive,@PropertyId)
		-------------------------------------------------------------------------------------------------


		
	END
END

GO

