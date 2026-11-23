

CREATE   PROCEDURE [dbo].[KioskItemType_M_Save]
    @Id             INT,
    @KioskItemType  VARCHAR(255),
    @SortOrder      INT,
    @IsActive       BIT,
    @Operation      VARCHAR(1)
AS
BEGIN
    SET NOCOUNT ON;

    SET @KioskItemType = LTRIM(RTRIM(ISNULL(@KioskItemType, '')));

    IF @KioskItemType = ''
    BEGIN
        RAISERROR('Kiosk Item Type is required.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.KIOSK_ItemType
               WHERE KioskItemType = @KioskItemType
                 AND (@Operation = 'I' OR Id <> @Id))
    BEGIN
        RAISERROR('That kiosk item type already exists.', 16, 1);
        RETURN;
    END

    IF @Operation = 'U'
    BEGIN
        UPDATE dbo.KIOSK_ItemType
           SET KioskItemType = @KioskItemType,
               SortOrder     = @SortOrder,
               IsActive      = @IsActive
         WHERE Id = @Id;

        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('That kiosk item type no longer exists.', 16, 1);
            RETURN;
        END
    END
    ELSE
    BEGIN
        INSERT INTO dbo.KIOSK_ItemType (KioskItemType, SortOrder, IsActive)
        VALUES (@KioskItemType, @SortOrder, @IsActive);

        SET @Id = SCOPE_IDENTITY();
    END

    -- TRANSFER FROM HO TO OUTLET SYNC (same as MainMenu / KioskCat) : one row per active outlet,
    -- picked up by the DataSync service (Sync_spGetKioskItemTypeList, Data Sync HO script 76)
    DELETE FROM dbo.Sync_MasterDataTransferStatus
    WHERE  DataType = 'KioskItemType' AND Code = CAST(@Id AS VARCHAR(10));

    INSERT INTO dbo.Sync_MasterDataTransferStatus (PropertyId, Code, Outlet, DataType, Active)
    SELECT L.PropertyId, CAST(@Id AS VARCHAR(10)), L.code, 'KioskItemType', @IsActive
    FROM   dbo.Location_Ref L
    WHERE  L.Active = 1;

    SELECT Id, KioskItemType, SortOrder, IsActive
    FROM   dbo.KIOSK_ItemType
    WHERE  Id = @Id;
END

GO

