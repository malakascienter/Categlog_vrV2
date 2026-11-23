

CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedPCurrency]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@CurrCode VARCHAR(6)
AS


IF @IsRestaurant = 0 
	BEGIN
		UPDATE	POS_CurrencyRates SET IsUpload = 1
		WHERE	CurrCode = @CurrCode AND PropertyId = @PropertyId 
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'Currency' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @CurrCode
	END

GO

