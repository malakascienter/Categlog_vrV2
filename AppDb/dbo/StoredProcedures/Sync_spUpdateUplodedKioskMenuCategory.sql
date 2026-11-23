CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedKioskMenuCategory]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@CategoryID INT
AS
IF @IsRestaurant = 1
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus
		WHERE	DataType = 'KioskCat' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = CAST(@CategoryID AS VARCHAR(20))
	END

GO

