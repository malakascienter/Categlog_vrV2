



CREATE PROCEDURE [dbo].[Sync_spGetTableCategoryList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS

IF @IsRestaurant = 0 
	BEGIN
		SELECT	TableCategoryID, TableCategoryName, OutletID, IsActive, SequenceID
		FROM	POS_TableCategories
		WHERE	PropertyId = @PropertyId AND IsUpload = 0
	END
ELSE
	BEGIN
		SELECT  T.TableCategoryID, T.TableCategoryName, T.OutletID, T.IsActive, T.SequenceID
		FROM    Sync_MasterDataTransferStatus S INNER JOIN POS_TableCategories T ON S.Code = T.TableCategoryID AND S.PropertyId = T.PropertyId
		WHERE	S.DataType = 'TableCategory' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

