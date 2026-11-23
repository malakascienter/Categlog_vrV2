



CREATE PROCEDURE [dbo].[Sync_spGetReservationList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	ReservationNo
		FROM	Reservation
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  Code AS ReservationNo
		FROM    Sync_MasterDataTransferStatus 
		WHERE	DataType = 'Reservation' AND PropertyId = @PropertyId AND Outlet = @OutletCode
	END

GO

