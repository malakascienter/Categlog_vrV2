
CREATE PROCEDURE [dbo].[POS_SetMenuLevel_Update] 
	@LevelCode	nvarchar(10),
	@LevelName	nvarchar(50),
	@IsActive	BIT,
	@User       INT,
	@PropertyId INT
	
AS
BEGIN

	DECLARE @SetMenuItemCode VARCHAR(10)
	DECLARE @Id BIGINT
	
	IF EXISTS(SELECT 1 FROM POS_SetMenuLevels WHERE SetMenuLevelID = @LevelCode AND PropertyId = @PropertyId )
	BEGIN

	   
		
		UPDATE [dbo].[POS_SetMenuLevels]
		   SET --[SetMenuLevelID] = @LevelCode
			  [Description] =@LevelName
			  ,[IsActive] = @IsActive
			  ,ModifiedUserId = @User
			  ,ModifiedDateTime = getdate()
		WHERE SetMenuLevelID = @LevelCode AND PropertyId = @PropertyId


		 SELECT @Id = Id FROM POS_SetMenuLevels WHERE SetMenuLevelID = @LevelCode AND PropertyId = @PropertyId
		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'POS_SetMenuLevels',@Id,'POS','POSSMU','U',@User,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

	END
	ELSE
	BEGIN
		
		RAISERROR('This level is not exist', 16, 1)
		-------------------------------------------------------------------------------------------------


		
	END
END

GO

