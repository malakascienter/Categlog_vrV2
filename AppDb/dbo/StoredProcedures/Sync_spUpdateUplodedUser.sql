



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedUser]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@UserID INT
AS

IF @IsRestaurant = 0 
	BEGIN
		UPDATE	Users SET IsUpload = 1
		WHERE	ID = @UserID AND PropertyId = @PropertyId 
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'User' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @UserID
	END

GO

