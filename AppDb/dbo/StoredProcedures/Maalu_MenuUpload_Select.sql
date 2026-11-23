
-- EXEC [Maalu_MenuUpload_Select] 4, 1, '300'
CREATE PROCEDURE [dbo].[Maalu_MenuUpload_Select]
    @AggType       INT,
    @PropertyId    INT,
    @Outlet        VARCHAR(5),
    @ChannelCode   VARCHAR(5)   = '008',
    @CurrencyCode  VARCHAR(3)   = 'LKR',
    @ImageBaseURL  VARCHAR(200) = 'https://api.pos.maalu.lk/ItemImages/'
AS
BEGIN
    SET NOCOUNT ON;

    /* Channel context - the Uber procedure joins ChannelDetails inline; the
       same three values are read into variables here so the outer FOR JSON
       does not need a driving table. */
    DECLARE @DefaultPriceTypeId  INT,
            @OrderType           VARCHAR(1),
            @ChannelAggregatorId INT;

    SELECT TOP (1)
           @DefaultPriceTypeId  = DefaultPriceTypeId,
           @OrderType           = OrderType,
           @ChannelAggregatorId = AggregatorId
    FROM dbo.ChannelDetails
    WHERE ChannelCode = @ChannelCode;

    IF @ChannelAggregatorId IS NULL
    BEGIN
        RAISERROR('Maalu_MenuUpload_Select: no ChannelDetails row for ChannelCode %s.', 16, 1, @ChannelCode);
        RETURN;
    END

    ------------------------------------------------------------------------
    -- Staging
    ------------------------------------------------------------------------
    CREATE TABLE #TempMainMenu
        (ItemCode VARCHAR(10), Description VARCHAR(200), Category VARCHAR(50), FullName VARCHAR(MAX));

    CREATE TABLE #TempModifier
        (ModifierMenuCode VARCHAR(10), ActionID VARCHAR(50), MinQty INT, MaxQty INT,
         MenuCode VARCHAR(10), ACType VARCHAR(1));

    CREATE TABLE #TempModifierMainItem
        (MainMenuCode VARCHAR(10), ActionID VARCHAR(50), ACType VARCHAR(1));

    CREATE TABLE #TempActionButton
        (ID VARCHAR(10), Name VARCHAR(50), MinQty INT, MaxQty INT,
         MenuCode VARCHAR(10), ACType VARCHAR(1));

    -- Items mapped to this aggregator for this outlet.
    INSERT INTO #TempMainMenu (ItemCode, Description, Category, FullName)
    SELECT MM.ItemCode, MM.Description, MM.Category, MM.Description
    FROM dbo.Category CT
    INNER JOIN dbo.MainMenu MM
        ON CT.Code = MM.Category AND MM.PropertyId = CT.PropertyId
    INNER JOIN dbo.AggregatorWiseMenuItem AM
        ON MM.ItemCode = AM.MenuCode AND MM.PropertyId = AM.PropertyId
    WHERE AM.AggregatorId = @AggType
      AND AM.Outlet       = @Outlet
      AND AM.PropertyId   = @PropertyId
      AND MM.PropertyId   = @PropertyId
      AND CT.PropertyId   = @PropertyId
      AND MM.IsMainPage   = 0
    ORDER BY MM.Seq ASC;

    -- Modifier source 1: plain modifiers.
    INSERT INTO #TempModifier (ModifierMenuCode, ActionID, MinQty, MaxQty, MenuCode, ACType)
    SELECT CT.ModifierMenuCode, CT.ActionID, 0, 1, CT.MainMenuCode, 'M'
    FROM dbo.MenuItemWiseModifier CT
    INNER JOIN #TempMainMenu MM ON CT.MainMenuCode = MM.ItemCode
    GROUP BY CT.ModifierMenuCode, CT.ActionID, CT.MainMenuCode;

    -- Modifier source 2: set menu levels.
    -- POS_SetMenuLevelDetails has no MinQuantity: an optional level floors at 0,
    -- otherwise LevelQuantity is the required number of picks.
    INSERT INTO #TempModifier (ModifierMenuCode, ActionID, MinQty, MaxQty, MenuCode, ACType)
    SELECT CT.MenuItemID,
           SL.SetMenuLevelID,
           MIN(CASE WHEN SML.IsOptional = 1 THEN 0 ELSE SML.LevelQuantity END),
           MAX(SML.MaxQuantity),
           CT.SetMenuItemID,
           'S'
    FROM dbo.POS_SetMenuItemDetails CT
    INNER JOIN #TempMainMenu MM ON CT.SetMenuItemID = MM.ItemCode
    INNER JOIN dbo.POS_SetMenuLevelDetails SML
        ON CT.SetMenuLevelID = SML.SetMenuLevelID AND CT.SetMenuItemID = SML.SetMenuItemID
    INNER JOIN dbo.POS_SetMenuLevels SL
        ON SL.SetMenuLevelID = CT.SetMenuLevelID
    WHERE SL.IsActive = 1
      -- POS_SetMenuLevels is keyed on (SetMenuLevelID, PropertyId): without this the
      -- same level id belonging to another property duplicates every group.
      AND SL.PropertyId = @PropertyId
    GROUP BY CT.MenuItemID, SL.SetMenuLevelID, CT.SetMenuItemID;

    -- A modifier that is not itself an uploaded item cannot be referenced.
    DELETE FROM #TempModifier
    WHERE ModifierMenuCode NOT IN (SELECT ItemCode FROM #TempMainMenu);

    -- Which items own which groups.
    INSERT INTO #TempModifierMainItem (MainMenuCode, ActionID, ACType)
    SELECT CT.MainMenuCode, CT.ActionID, 'M'
    FROM dbo.MenuItemWiseModifier CT
    INNER JOIN #TempMainMenu MM ON CT.MainMenuCode = MM.ItemCode
    GROUP BY CT.MainMenuCode, CT.ActionID;

    INSERT INTO #TempModifierMainItem (MainMenuCode, ActionID, ACType)
    SELECT CT.SetMenuItemID, SL.SetMenuLevelID, 'S'
    FROM dbo.POS_SetMenuItemDetails CT
    INNER JOIN #TempMainMenu MM ON CT.SetMenuItemID = MM.ItemCode
    INNER JOIN dbo.POS_SetMenuLevels SL ON SL.SetMenuLevelID = CT.SetMenuLevelID
    WHERE SL.IsActive = 1
      AND SL.PropertyId = @PropertyId
    GROUP BY CT.SetMenuItemID, SL.SetMenuLevelID;

    -- The groups themselves.
    INSERT INTO #TempActionButton (ID, Name, MinQty, MaxQty, MenuCode, ACType)
    SELECT AB.ID, AB.DisplayName, MIN(TAB.MinQty), MAX(TAB.MaxQty), TAB.MenuCode, 'M'
    FROM #TempModifier TAB
    INNER JOIN dbo.ActionButtons AB ON TAB.ActionID = AB.ID
    WHERE TAB.ACType = 'M'
    GROUP BY AB.ID, AB.DisplayName, TAB.MenuCode;

    INSERT INTO #TempActionButton (ID, Name, MinQty, MaxQty, MenuCode, ACType)
    SELECT AB.SetMenuLevelID, AB.Description, MIN(TAB.MinQty), MAX(TAB.MaxQty), TAB.MenuCode, 'S'
    FROM #TempModifier TAB
    INNER JOIN dbo.POS_SetMenuLevels AB ON TAB.ActionID = AB.SetMenuLevelID
    WHERE TAB.ACType = 'S'
      AND AB.IsActive = 1
      AND AB.PropertyId = @PropertyId
    GROUP BY AB.SetMenuLevelID, AB.Description, TAB.MenuCode;

    ------------------------------------------------------------------------
    -- Payload
    ------------------------------------------------------------------------
    ;WITH JsonTab(MenuJson) AS
    (
        SELECT
        (
            SELECT
                /* ---- menus[] ---------------------------------------------- */
                JSON_QUERY(ISNULL((
                    SELECT
                        CONCAT(PIT.Id, '_M') AS [id],
                        PIT.Name             AS [name],
                        /* One row per Category, so no DISTINCT is needed and no derived
                           table is involved - SQL Server does not allow an outer reference
                           (PIT.Code) inside a derived table, only inside a correlated
                           predicate like the EXISTS below. */
                        JSON_QUERY(ISNULL((
                            SELECT '["' + STRING_AGG(STRING_ESCAPE(CAST(CT.CatgId AS VARCHAR(20)), 'json'), '","') + '"]'
                            FROM dbo.Category CT
                            WHERE CT.PropertyId = @PropertyId
                              AND EXISTS (
                                    SELECT 1
                                    FROM #TempMainMenu S
                                    INNER JOIN dbo.MainMenu MM
                                        ON MM.ItemCode = S.ItemCode AND MM.PropertyId = @PropertyId
                                    WHERE S.Category = CT.Code
                                      AND MM.ItemType = PIT.Code
                                      AND S.ItemCode NOT IN (SELECT ModifierMenuCode FROM #TempModifier))
                            ), '[]')) AS [category_ids],
                        JSON_QUERY(ISNULL((
                            SELECT
                                USA.DayName AS [day_of_week],
                                JSON_QUERY((
                                    SELECT
                                        CONVERT(VARCHAR(5), PIT.FromTime, 108) AS [start_time],
                                        CONVERT(VARCHAR(5), PIT.ToTime,   108) AS [end_time]
                                    FOR JSON PATH)) AS [time_periods]
                            FROM dbo.ItemTypeWiseMaalu_ServiceAvailability USA
                            WHERE USA.ItemTypeId = PIT.Id
                            FOR JSON PATH), '[]')) AS [service_availability]
                    FROM dbo.POSItemTypes PIT
                    WHERE PIT.PropertyId = @PropertyId
                      AND PIT.Code IN (SELECT MM.ItemType
                                       FROM dbo.MainMenu MM
                                       WHERE MM.ItemCode IN (SELECT ItemCode FROM #TempMainMenu)
                                         AND MM.PropertyId = @PropertyId)
                    FOR JSON PATH), '[]')) AS [menus],

                /* ---- categories[] ------------------------------------------ */
                JSON_QUERY(ISNULL((
                    SELECT
                        CAST(CT.CatgId AS VARCHAR(20)) AS [id],
                        CT.Description                 AS [name],
                        JSON_QUERY(ISNULL((
                            SELECT '["' + STRING_AGG(STRING_ESCAPE(S.ItemCode, 'json'), '","')
                                          WITHIN GROUP (ORDER BY SBMM.Seq ASC) + '"]'
                            FROM #TempMainMenu S
                            INNER JOIN dbo.MainMenu SBMM
                                ON S.ItemCode = SBMM.ItemCode AND SBMM.PropertyId = @PropertyId
                            WHERE S.Category = CT.Code
                              AND S.ItemCode NOT IN (SELECT ModifierMenuCode FROM #TempModifier)
                            ), '[]')) AS [item_ids]
                    FROM dbo.Category CT
                    WHERE CT.PropertyId = @PropertyId
                      AND CT.Code IN (SELECT Category FROM #TempMainMenu
                                      WHERE ItemCode NOT IN (SELECT ModifierMenuCode FROM #TempModifier))
                    ORDER BY CT.Seq ASC
                    FOR JSON PATH), '[]')) AS [categories],

                /* ---- items[] ----------------------------------------------- */
                JSON_QUERY(ISNULL((
                    SELECT
                        S.ItemCode      AS [id],
                        S.Description   AS [name],
                        S.FullName      AS [description],
                        CAST(1 AS BIT)  AS [available],
                        CONCAT(@ImageBaseURL,
                               ISNULL((SELECT TOP (1) IMG.ImageName
                                       FROM dbo.POS_Image IMG
                                       WHERE IMG.Code = S.ItemCode
                                         AND IMG.DataType = 'ITM'
                                         AND IMG.PropertyId = @PropertyId), '')) AS [image_url],
                        /* #TempModifierMainItem and #TempActionButton are both built with
                           GROUP BY, so the join produces at most one row per group and no
                           DISTINCT is required - which is what lets the outer reference
                           (S.ItemCode) stay in a plain WHERE rather than a derived table. */
                        JSON_QUERY(ISNULL((
                            SELECT '["' + STRING_AGG(
                                       STRING_ESCAPE(CONCAT(AB.ID, '_', AB.ID, '_', AB.MenuCode, '_', AB.ACType), 'json'),
                                       '","') + '"]'
                            FROM #TempModifierMainItem MC
                            INNER JOIN #TempActionButton AB
                                ON MC.ActionID = AB.ID
                               AND MC.MainMenuCode = AB.MenuCode
                               AND AB.ACType = MC.ACType
                            WHERE MC.MainMenuCode = S.ItemCode
                            ), '[]')) AS [modifier_group_ids],
                        CONVERT(BIGINT, ROUND(ISNULL((
                                SELECT TOP (1) P.Price
                                FROM dbo.POS_OutletWiseMenuItemPrice P
                                WHERE P.OutletCode   = @Outlet
                                  AND P.PriceTypeID  = @DefaultPriceTypeId
                                  AND P.PropertyId   = @PropertyId
                                  AND P.MenuItemCode = S.ItemCode), 0) * 100, 0))
                                                          AS [price_info.price],
                        @CurrencyCode                     AS [price_info.currency_code],
                        CAST(0 AS BIT)                    AS [suspension_info.is_suspended],
                        [dbo].[AGGR_fnGetItemWiseResNetVal](S.ItemCode, @OrderType, 0, 0, 0, @ChannelAggregatorId, 0)
                                                          AS [tax_info.tax_rate],
                        ''                                AS [tax_info.vat_rate_percentage]
                    FROM #TempMainMenu S
                    FOR JSON PATH), '[]')) AS [items],

                /* ---- modifier_groups[] -------------------------------------- */
                JSON_QUERY(ISNULL((
                    SELECT
                        CONCAT(CT.ID, '_', CT.ID, '_', CT.MenuCode, '_', CT.ACType) AS [id],
                        CT.Name                  AS [name],
                        ISNULL(CT.MinQty, 0)     AS [min_permitted],
                        ISNULL(CT.MaxQty, 1)     AS [max_permitted],
                        JSON_QUERY(ISNULL((
                            SELECT
                                OPT.ItemCode    AS [id],
                                OPT.Description AS [name],
                                CONVERT(BIGINT, ROUND(ISNULL((
                                        SELECT TOP (1) P.Price
                                        FROM dbo.POS_OutletWiseMenuItemPrice P
                                        WHERE P.OutletCode   = @Outlet
                                          AND P.PriceTypeID  = @DefaultPriceTypeId
                                          AND P.PropertyId   = @PropertyId
                                          AND P.MenuItemCode = OPT.ItemCode), 0) * 100, 0))
                                                AS [price_info.price],
                                @CurrencyCode   AS [price_info.currency_code]
                            FROM #TempMainMenu OPT
                            INNER JOIN #TempModifier M ON M.ModifierMenuCode = OPT.ItemCode
                            WHERE M.ActionID = CT.ID
                              AND M.MenuCode = CT.MenuCode
                              AND M.ACType   = CT.ACType
                            FOR JSON PATH), '[]')) AS [options]
                    FROM #TempActionButton CT
                    FOR JSON PATH), '[]')) AS [modifier_groups]

            FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
        )
    )
    SELECT MenuJson FROM JsonTab;

    DROP TABLE #TempMainMenu;
    DROP TABLE #TempModifier;
    DROP TABLE #TempModifierMainItem;
    DROP TABLE #TempActionButton;
END

GO

