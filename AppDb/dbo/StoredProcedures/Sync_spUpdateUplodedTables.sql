



CREATE PROCEDURE [dbo].[Sync_spUpdateUplodedTables]

@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5),
@TableID INT
AS

IF @IsRestaurant = 0 
	BEGIN
		UPDATE	POS_TableList SET IsUpload = 1 WHERE TableID = @TableID
	END
ELSE
	BEGIN
		DELETE	FROM Sync_MasterDataTransferStatus 
		WHERE	DataType = 'Table' AND PropertyId = @PropertyId AND Outlet = @OutletCode AND Code = @TableID
	END

GO

