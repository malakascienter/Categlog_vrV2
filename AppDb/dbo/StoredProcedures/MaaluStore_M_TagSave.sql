
CREATE PROCEDURE dbo.MaaluStore_M_TagSave
    @PropertyId int,
    @OutletCode varchar(5),
    @StoreId    varchar(200)
AS
BEGIN
    SET NOCOUNT ON;

    SET @StoreId = NULLIF(LTRIM(RTRIM(ISNULL(@StoreId, ''))), '');

    IF NOT EXISTS (SELECT 1 FROM dbo.Location_Ref
                   WHERE code = @OutletCode AND PropertyId = @PropertyId)
    BEGIN
        SELECT CAST(0 AS bit) AS Success,
               'Outlet ' + @OutletCode + ' does not exist.' AS Message;
        RETURN;
    END

    /* Clearing the tag is allowed - it takes the outlet out of the module. */
    IF @StoreId IS NOT NULL
    BEGIN
        DECLARE @ClashOutlet varchar(5);

        SELECT TOP (1) @ClashOutlet = code
        FROM dbo.Location_Ref
        WHERE Maalu_StoreId = @StoreId
          AND NOT (code = @OutletCode AND PropertyId = @PropertyId);

        IF @ClashOutlet IS NOT NULL
        BEGIN
            SELECT CAST(0 AS bit) AS Success,
                   'Store id ' + @StoreId + ' is already tagged to outlet '
                   + @ClashOutlet + '. One store id maps to exactly one outlet.' AS Message;
            RETURN;
        END
    END

    UPDATE dbo.Location_Ref
       SET Maalu_StoreId = @StoreId
     WHERE code = @OutletCode AND PropertyId = @PropertyId;

    IF COL_LENGTH('dbo.BrandWiseOutletMapping', 'Maalu_StoreId') IS NOT NULL
        UPDATE dbo.BrandWiseOutletMapping
           SET Maalu_StoreId = @StoreId
         WHERE Code = @OutletCode AND PropertyId = @PropertyId;

    /* The cached status no longer describes the newly tagged store. */
    UPDATE dbo.POS_MaaluStoreStatus
       SET Maalu_StoreId = @StoreId,
           Status        = 'UNKNOWN',
           OfflineReason = NULL,
           LastSyncedOn  = NULL,
           UpdatedOn     = GETDATE()
     WHERE PropertyId = @PropertyId
       AND OutletCode = @OutletCode
       AND ISNULL(Maalu_StoreId, '') <> ISNULL(@StoreId, '');

    SELECT CAST(1 AS bit) AS Success,
           CASE WHEN @StoreId IS NULL
                THEN 'Store id cleared.'
                ELSE 'Store id saved.' END AS Message;
END

GO

