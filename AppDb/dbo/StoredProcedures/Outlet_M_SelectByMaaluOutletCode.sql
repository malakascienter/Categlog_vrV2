
CREATE PROCEDURE [dbo].[Outlet_M_SelectByMaaluOutletCode]
    @PropertyId int,
    @OutletCode varchar(5)
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
    WHERE mc.PropertyId     = @PropertyId
      AND mc.OutletCode     = @OutletCode
      AND mc.IsMaaluEnabled = 1;
END

GO

