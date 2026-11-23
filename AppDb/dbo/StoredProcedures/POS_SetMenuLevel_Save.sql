
CREATE PROCEDURE [dbo].[POS_SetMenuLevel_Save] 
	@LevelCode	nvarchar(10),
	@LevelName	nvarchar(50),
	@IsActive	BIT,
	@User       INT,
	@PropertyId INT
	
AS
BEGIN
	DECLARE @Id BIGINT
	DECLARE @SetMenuItemCode VARCHAR(10)
		
	IF EXISTS(SELECT 1 FROM POS_SetMenuLevels WHERE SetMenuLevelID = @LevelCode AND PropertyId = @PropertyId )
	BEGIN
		RAISERROR('This level for set menu is already added', 16, 1)
	END
	ELSE
	BEGIN
		
		INSERT INTO POS_SetMenuLevels(SetMenuLevelID, Description,IsActive,ModifiedUserId,ModifiedDateTime,PropertyId)
		VALUES(@LevelCode, @LevelName,@IsActive,@User,GETDATE(),@PropertyId)

		SET @Id = SCOPE_IDENTITY()

			-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'POS_SetMenuLevels',@Id,'POS','POSSMI','I',@User,'','','','','',@PropertyId
		-- End of Audit trail ---------------------

		-------------------------------------------------------------------------------------------------
		UPDATE M
		SET M.IsUpload = 0
		FROM POS_SetMenuLevelDetails P INNER JOIN MainMenu M ON P.SetMenuItemID = M.ItemCode AND P.PropertyId = M.PropertyId
		WHERE  P.SetMenuLevelID = @LevelCode AND P.PropertyId = @PropertyId

		IF( (SELECT IsRestaurant FROM Companies WHERE CompanyID = @PropertyId) = 1 )
		BEGIN

		  --TRANSFER FROM HO TO OUTLET SYNC
			INSERT INTO Sync_MasterDataTransferStatus(PropertyId,Code,Outlet,DataType,Active)
			SELECT @PropertyId,M.ItemCode,L.code,'MainMenu',@IsActive
			FROM POS_SetMenuLevelDetails P INNER JOIN MainMenu M ON P.SetMenuItemID = M.ItemCode AND P.PropertyId = M.PropertyId
			CROSS JOIN Location_Ref L
			WHERE  P.SetMenuLevelID = @LevelCode AND P.PropertyId = @PropertyId AND L.Active = 1 AND L.PropertyId = @PropertyId

		END


		
		
	END
END

GO

