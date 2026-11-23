
CREATE PROCEDURE [dbo].[Sync_spGetUserList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	Id AS UserID, Username, POSPassword, AccessCardNo, IsActive, ContactNo
		FROM	Users
		WHERE	PropertyId = @PropertyId AND IsUpload = 0 AND IsPOSUser = 1 AND AccessCardNo != ''
	END
ELSE
	BEGIN
		SELECT  U.Id AS UserID, U.Username, U.POSPassword, U.AccessCardNo, U.IsActive, U.ContactNo
		FROM    Sync_MasterDataTransferStatus S INNER JOIN Users U ON S.Code = U.Id AND S.PropertyId = U.PropertyId
		WHERE	S.DataType = 'User' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode AND U.AccessCardNo != ''
	END

GO

