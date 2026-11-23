



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedMenuItems]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@MenuItem VARCHAR(6)
AS

	IF @IsRestaurant = 0 
		BEGIN
			UPDATE	MainMenu SET IsUpload = 1
			WHERE	ItemCode = @MenuItem AND PropertyId = @PropertyId 
		END
	ELSE
		BEGIN
			DELETE	FROM Sync_MasterDataTransferStatus 
			WHERE	DataType = 'MainMenu' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @MenuItem
		END

GO

