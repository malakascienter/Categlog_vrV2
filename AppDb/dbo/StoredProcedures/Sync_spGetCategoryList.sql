




CREATE PROCEDURE [dbo].[Sync_spGetCategoryList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	Code, Description, Colour, Seq
		FROM	Category
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  C.Code, C.Description, C.Colour, C.Seq
		FROM    Sync_MasterDataTransferStatus S INNER JOIN Category C ON S.Code = C.Code AND S.PropertyId = C.PropertyId
		WHERE	S.DataType = 'Category' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

