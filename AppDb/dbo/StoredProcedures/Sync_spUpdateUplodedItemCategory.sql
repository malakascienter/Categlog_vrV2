




CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedItemCategory]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@ID INT

AS
	IF @IsRestaurant = 0 
		BEGIN
			UPDATE	ItemCategory SET IsUpload = 1
			WHERE	ID = @ID AND PropertyId = @PropertyId 
		END
	ELSE
		BEGIN
			DELETE	FROM Sync_MasterDataTransferStatus 
			WHERE	DataType = 'ItemType' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @ID
		END

GO

