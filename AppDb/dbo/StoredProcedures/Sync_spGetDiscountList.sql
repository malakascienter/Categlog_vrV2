


CREATE PROCEDURE [dbo].[Sync_spGetDiscountList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	Code, IsActive
		FROM	DiscountHeader
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  Code, Active AS IsActive
		FROM    Sync_MasterDataTransferStatus
		WHERE	DataType = 'Discount' AND PropertyId = @PropertyId AND Outlet = @OutletCode
	END

GO

