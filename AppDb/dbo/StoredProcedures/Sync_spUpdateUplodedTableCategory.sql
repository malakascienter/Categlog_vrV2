



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedTableCategory]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@TableCategoryID INT
AS

IF @IsRestaurant = 0 
	BEGIN
		UPDATE	POS_TableCategories SET IsUpload = 1 WHERE TableCategoryID = @TableCategoryID
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'TableCategory' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @TableCategoryID
	END

GO

