




CREATE PROCEDURE [dbo].[Sync_spGetItemCategoryList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	ID,Code,Name,IsActive
		FROM	ItemCategory
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  C.ID, C.Code, C.Name, C.IsActive
		FROM    Sync_MasterDataTransferStatus S INNER JOIN ItemCategory C ON S.Code = C.ID AND S.PropertyId = C.PropertyId
		WHERE	S.DataType = 'ItemType' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

