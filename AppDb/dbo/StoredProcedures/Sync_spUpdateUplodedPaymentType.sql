



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedPaymentType]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@PayCode VARCHAR(6)
AS


IF @IsRestaurant = 0 
	BEGIN
		UPDATE	PaymentTypes SET IsUpload = 1
		WHERE	PayCode = @PayCode AND PropertyId = @PropertyId 
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'PaymentTypes' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @PayCode
	END

GO

