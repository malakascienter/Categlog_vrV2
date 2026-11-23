CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedKioskItemType]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@Id INT
AS
IF @IsRestaurant = 1
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus
		WHERE	DataType = 'KioskItemType' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = CAST(@Id AS VARCHAR(10))
	END

GO

