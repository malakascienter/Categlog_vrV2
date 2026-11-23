



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedCategory]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@CategoryCode VARCHAR(6)

AS
IF @IsRestaurant = 0 
	BEGIN
		UPDATE	Category SET IsUpload = 1
		WHERE	Code = @CategoryCode AND PropertyId = @PropertyId 
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'Category' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @CategoryCode
	END

GO

