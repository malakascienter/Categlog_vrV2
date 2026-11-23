

CREATE PROCEDURE [dbo].[SP_SetMenuLevel_Save]
(
	@SetMenuLevelId VARCHAR(4),
	@Description VARCHAR(30),
	@UserId INT = -1,
	@Operation CHAR(1)
)

AS
BEGIN
SET NOCOUNT ON;
	IF(@Operation = 'I')
		BEGIN
		 IF EXISTS (SELECT 1 FROM POS_SetMenuLevels WHERE SetMenuLevelID = @SetMenuLevelId)
		 BEGIN
		    RAISERROR('Level code already exists.',16,1)
			
		 END
		 ELSE 
		 BEGIN
		    INSERT INTO POS_SetMenuLevels(SetMenuLevelID, Description, CreatedUserId, CreatedDateTime)
			VALUES(@SetMenuLevelId, @Description,@UserId, GETDATE())
		 END
         END
		 ELSE IF(@Operation = 'U')
		 BEGIN
		 IF EXISTS (SELECT 1 FROM POS_SetMenuLevels WHERE SetMenuLevelID = @SetMenuLevelId)
		 BEGIN
			UPDATE  POS_SetMenuLevels
		    SET			
			Description = @Description,
			ModifiedUserId = @UserId,
			ModifiedDateTime = GETDATE()
			WHERE SetMenuLevelID = @SetMenuLevelId 
		END
		ELSE
		BEGIN
			RAISERROR('No record exists.',16,1)
		END		
	END
	ELSE
	BEGIN
		RAISERROR('Invalid operation',16,1)
	END

END

GO

