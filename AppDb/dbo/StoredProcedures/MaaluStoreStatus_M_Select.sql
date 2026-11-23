
CREATE PROCEDURE dbo.MaaluStoreStatus_M_Select
    @PropertyId int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        lr.code                                        AS Outlet,
        lr.description                                 AS Description,
        ISNULL(lr.Maalu_StoreId, '')                   AS Maalu_StoreId,
        ISNULL(ss.Status, 'UNKNOWN')                   AS Status,
        ISNULL(ss.OfflineReason, '')                   AS OfflineReason,
        -- style 126 on a datetime yields yyyy-mm-ddThh:mm:ss.mmm; varchar(19) keeps
        -- the seconds and drops the milliseconds, giving a clean ISO 8601 value.
        ISNULL(CONVERT(varchar(19), ss.PausedUntil, 126) + 'Z', '')  AS PausedUntilUtc,
        ISNULL(ss.Reason, '')                          AS Reason,
        ISNULL(CONVERT(varchar(19), ss.LastSyncedOn, 120), '')       AS LastSyncedText,
        ISNULL(ss.UpdatedBy, '')                       AS UpdatedBy,
        CASE WHEN NULLIF(LTRIM(RTRIM(lr.Maalu_StoreId)), '') IS NULL
             THEN CAST(0 AS bit) ELSE CAST(1 AS bit) END AS IsTagged,
        CASE WHEN mc.OutletCode IS NULL
             THEN CAST(0 AS bit) ELSE ISNULL(mc.IsMaaluEnabled, CAST(0 AS bit)) END AS IsMaaluEnabled
    FROM dbo.Location_Ref lr
    LEFT JOIN dbo.POS_MaaluStoreStatus ss
        ON  ss.OutletCode = lr.code
        AND ss.PropertyId = lr.PropertyId
    LEFT JOIN dbo.POS_MaaluOutletConfig mc
        ON  mc.OutletCode = lr.code
        AND mc.PropertyId = lr.PropertyId
    WHERE lr.PropertyId = @PropertyId
      AND lr.Active     = 1
    ORDER BY lr.description;
END

GO

