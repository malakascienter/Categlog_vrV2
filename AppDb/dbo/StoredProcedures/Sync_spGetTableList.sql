



CREATE PROCEDURE [dbo].[Sync_spGetTableList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	TableID, TableCategoryID, TableName, IsActive, SequenceID
		FROM	POS_TableList
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  T.TableID, T.TableCategoryID, T.TableName, T.IsActive, T.SequenceID
		FROM    Sync_MasterDataTransferStatus S INNER JOIN POS_TableList T ON S.Code = T.TableID AND S.PropertyId = T.PropertyId
		WHERE	S.DataType = 'Table' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

