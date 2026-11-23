



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedReservation]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@ReservationNo INT
AS

	IF @IsRestaurant = 0 
		BEGIN
			UPDATE	Reservation SET IsUpload = 1
			WHERE	ReservationNo = @ReservationNo AND PropertyId = @PropertyId 
		END
	ELSE
		BEGIN
			DELETE	FROM Sync_MasterDataTransferStatus 
			WHERE	DataType = 'Reservation' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @ReservationNo
		END

GO

