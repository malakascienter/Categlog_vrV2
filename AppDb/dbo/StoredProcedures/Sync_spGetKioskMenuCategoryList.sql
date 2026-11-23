CREATE PROCEDURE [dbo].[Sync_spGetKioskMenuCategoryList]
@PropertyId INT,
@IsRestaurant BIT,
@OutletCode VARCHAR(5)
AS
SET NOCOUNT ON

IF @IsRestaurant = 0
	BEGIN
		-- Kiosk categories are only queued for restaurant outlets
		SELECT	CategoryID, CategoryName, SortOrder, ItemType, CAST(0 AS BIT) AS IsDelete
		FROM	POS_KioskMenuCategory
		WHERE	1 = 0
	END
ELSE
	BEGIN
		-- Deleted or inactive categories come back with IsDelete = 1 so they are removed at the outlet
		SELECT	DISTINCT CAST(S.Code AS INT) AS CategoryID, K.CategoryName, K.SortOrder, K.ItemType,
				CAST(CASE WHEN K.CategoryID IS NULL OR K.IsActive = 0 THEN 1 ELSE 0 END AS BIT) AS IsDelete
		FROM	Sync_MasterDataTransferStatus S LEFT JOIN POS_KioskMenuCategory K ON S.Code = CAST(K.CategoryID AS VARCHAR(20))
		WHERE	S.DataType = 'KioskCat' AND S.PropertyId = @PropertyId AND S.Outlet = @OutletCode
	END

GO

