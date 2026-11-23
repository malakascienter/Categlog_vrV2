CREATE PROCEDURE [dbo].[Sync_spGetKioskItemTypeList]
@PropertyId INT = NULL,
@IsRestaurant BIT = NULL,
@OutletCode VARCHAR(5) = NULL
AS
SET NOCOUNT ON

IF @PropertyId IS NULL
	BEGIN
		-- Older service build : full list (74)
		SELECT	Id, KioskItemType, SortOrder, IsActive
		FROM	KIOSK_ItemType
		ORDER BY Id
	END
ELSE IF @IsRestaurant = 0
	BEGIN
		-- Kiosk item types are only queued for restaurant outlets
		SELECT	Id, KioskItemType, SortOrder, IsActive, CAST(0 AS BIT) AS IsDelete
		FROM	KIOSK_ItemType
		WHERE	1 = 0
	END
ELSE
	BEGIN
		-- Queued Ids for this outlet; IsDelete = 1 when the Id no longer exists at HO
		SELECT	DISTINCT Q.Id, K.KioskItemType, K.SortOrder, K.IsActive,
				CAST(CASE WHEN K.Id IS NULL THEN 1 ELSE 0 END AS BIT) AS IsDelete
		FROM	(SELECT TRY_CAST(Code AS INT) AS Id
				 FROM	Sync_MasterDataTransferStatus
				 WHERE	DataType = 'KioskItemType' AND PropertyId = @PropertyId AND Outlet = @OutletCode) Q
				LEFT JOIN KIOSK_ItemType K ON K.Id = Q.Id
		WHERE	Q.Id IS NOT NULL
		ORDER BY Q.Id
	END

GO

