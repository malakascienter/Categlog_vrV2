
CREATE PROCEDURE [dbo].[POS_SetMenu_T_DeleteLevel] 
	@LevelItemId	INT,
	@PropertyId INT
AS
BEGIN

     DECLARE @Id BIGINT

	 SELECT @Id = Id FROM POS_SetMenuLevels WHERE SetMenuLevelID = @LevelItemId AND PropertyId = @PropertyId
	 -- Audit trail ----------------------------		
	 EXEC HotelResWeb_AuditTail_WriteToLog 'POS_SetMenuLevels',@Id,'POS','POSSMD','D',0,'','','','','',@PropertyId
	 -- End of Audit trail ---------------------
	
	UPDATE POS_SetMenuLevels SET IsActive = 0
	WHERE SetMenuLevelID = @LevelItemId AND PropertyId = @PropertyId

END

GO

