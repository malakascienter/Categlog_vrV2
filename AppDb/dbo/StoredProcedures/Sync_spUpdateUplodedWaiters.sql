



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedWaiters]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@Code VARCHAR(8)
AS

IF @IsRestaurant = 0 
	BEGIN
		UPDATE	Waiter SET IsUpload = 1
		WHERE	Code = @Code AND PropertyId = @PropertyId 
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'Waiter' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @Code
	END

GO

