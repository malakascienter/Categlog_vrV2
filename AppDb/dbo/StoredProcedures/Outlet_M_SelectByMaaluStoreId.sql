
CREATE PROCEDURE [dbo].[Outlet_M_SelectByMaaluStoreId]
    @StoreId varchar(200)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 1
        o.Code                  AS Code,
        o.Description           AS Description,
        o.Active                AS Active,
        o.PropertyId            AS PropertyId,
        o.IPAddress             AS IPAddress,
        o.IPAddressALT          AS IPAddressALT,
        o.OutletDatabase        AS OutletDatabase,
        COALESCE(NULLIF(LTRIM(RTRIM(lr.Maalu_StoreId)), ''), mc.Maalu_StoreId) AS Maalu_StoreId,
        mc.Maalu_ChannelCode    AS Maalu_ChannelCode,
        mc.Maaluclient_id       AS Maaluclient_id,
        mc.Maaluclient_secret   AS Maaluclient_secret,
        mc.MaaluAggregatorType  AS MaaluAggregatorType,
        mc.IsMaaluEnabled       AS IsMaaluEnabled
    FROM POS_MaaluOutletConfig mc
    INNER JOIN Location_Ref o
        ON  o.Code       = mc.OutletCode
        AND o.PropertyId = mc.PropertyId
    LEFT JOIN Location_Ref lr
        ON  lr.code       = o.Code
        AND lr.PropertyId = o.PropertyId
    WHERE mc.IsMaaluEnabled = 1
      AND (   NULLIF(LTRIM(RTRIM(lr.Maalu_StoreId)), '') = @StoreId
           OR mc.Maalu_StoreId                           = @StoreId )
    /* Prefer the outlet whose Location_Ref tag matches, so a stale
       POS_MaaluOutletConfig value never wins over the tag. */
    ORDER BY CASE WHEN NULLIF(LTRIM(RTRIM(lr.Maalu_StoreId)), '') = @StoreId THEN 0 ELSE 1 END;
END

GO

