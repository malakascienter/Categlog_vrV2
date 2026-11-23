
CREATE PROCEDURE [dbo].[POS_SetMenuSubLevel_Update] 
	@SubLevelCode	nvarchar(10),
	@SubLevelName	nvarchar(50),
	@IsActive	bit,
	@PropertyId INT
AS
BEGIN

		
	IF EXISTS(SELECT 1 FROM POS_SetMenuSubLevels WHERE SetMenuSubLevelID = @SubLevelCode AND PropertyId = @PropertyId )
	BEGIN
	UPDATE [dbo].[POS_SetMenuSubLevels]
   SET --[SetMenuSubLevelID] = @SubLevelCode
      [Description] = @SubLevelName
      ,[IsActive] = @IsActive
 WHERE SetMenuSubLevelID = @SubLevelCode  AND PropertyId = @PropertyId
		
	END
	ELSE
	BEGIN
		RAISERROR('This sub level is not exist', 16, 1)
		
	END
END

GO

