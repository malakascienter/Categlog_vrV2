



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedDiscounts]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@DiscountsCode VARCHAR(2)
AS

	IF @IsRestaurant = 0 
		BEGIN
			UPDATE	DiscountHeader SET IsUpload = 1
			WHERE	Code = @DiscountsCode AND PropertyId = @PropertyId 
		END
	ELSE
		BEGIN
			DELETE	FROM Sync_MasterDataTransferStatus 
			WHERE	DataType = 'Discount' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @DiscountsCode
		END

GO

