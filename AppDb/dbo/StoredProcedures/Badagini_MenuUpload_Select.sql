
CREATE PROCEDURE [dbo].[Badagini_MenuUpload_Select]
    @AggType INT,
    @PropertyId INT,
    @Outlet VARCHAR(5),
    @BrandID INT
AS
BEGIN

    SET NOCOUNT ON;

    DECLARE @IsEnableBrandWiseMenu BIT;

    SELECT TOP (1)
        @IsEnableBrandWiseMenu = IsEnableBrandWiseMenu
    FROM Companies
    WHERE CompanyID = @PropertyId;


    IF (@IsEnableBrandWiseMenu = 0)
    BEGIN
        SET @BrandID = 0;
    END;


    /* =========================================================
       Temporary Tables
       ========================================================= */

    CREATE TABLE #JsonData
    (
        JsonData NVARCHAR(MAX)
    );


    CREATE TABLE #JsonResult
    (
        JsonData NVARCHAR(MAX)
    );


    CREATE TABLE #TempMainMenu
    (
        ItemCode VARCHAR(10),
        Description VARCHAR(200),
        Category VARCHAR(50),
        FullName VARCHAR(MAX)
    );


    CREATE TABLE #TempModifier
    (
        ModifierMenuCode VARCHAR(10),
        ActionID VARCHAR(50),
        MaxQty INT,
        MenuCode VARCHAR(10)
    );


    CREATE TABLE #TempModifierMainItem
    (
        MainMenuCode VARCHAR(10),
        ActionID VARCHAR(50)
    );


    CREATE TABLE #TempActionButton
    (
        ID VARCHAR(10),
        Name VARCHAR(50),
        MaxQty INT,
        MenuCode VARCHAR(10)
    );


    /* =========================================================
       Main Menu
       ========================================================= */

    INSERT INTO #TempMainMenu
    (
        ItemCode,
        Description,
        Category,
        FullName
    )
    SELECT
        MM.ItemCode,
        MM.Description,
        MM.Category,
        MM.Description AS FullName
    FROM Category CT
    INNER JOIN MainMenu MM
        ON CT.Code = MM.Category
        AND MM.PropertyId = CT.PropertyId
    INNER JOIN AggregatorWiseMenuItem AM
        ON MM.ItemCode = AM.MenuCode
        AND MM.PropertyId = AM.PropertyId
    WHERE AM.AggregatorId = @AggType
      AND AM.Outlet = @Outlet
      AND MM.PropertyId = @PropertyId
      AND CT.PropertyId = @PropertyId
      AND AM.PropertyId = @PropertyId
      AND AM.BrandID = @BrandID
    ORDER BY MM.Seq ASC;


    /* =========================================================
       Modifier - MenuItemWiseModifier
       ========================================================= */

    INSERT INTO #TempModifier
    (
        ModifierMenuCode,
        ActionID,
        MaxQty,
        MenuCode
    )
    SELECT
        CT.ModifierMenuCode,
        CT.ActionID,
        1,
        CT.MainMenuCode
    FROM MenuItemWiseModifier CT
    INNER JOIN #TempMainMenu MM
        ON CT.MainMenuCode = MM.ItemCode
    GROUP BY
        CT.ModifierMenuCode,
        CT.ActionID,
        CT.MainMenuCode;


    /* =========================================================
       Modifier - Set Menu
       ========================================================= */

    INSERT INTO #TempModifier
    (
        ModifierMenuCode,
        ActionID,
        MaxQty,
        MenuCode
    )
    SELECT
        CT.MenuItemID AS ModifierMenuCode,
        SL.SetMenuLevelID AS ActionID,
        SML.MaxQuantity,
        CT.SetMenuItemID
    FROM POS_SetMenuItemDetails CT
    INNER JOIN #TempMainMenu MM
        ON CT.SetMenuItemID = MM.ItemCode
    INNER JOIN POS_SetMenuLevelDetails SML
        ON CT.SetMenuLevelID = SML.SetMenuLevelID
        AND CT.SetMenuItemID = SML.SetMenuItemID
    INNER JOIN POS_SetMenuLevels SL
        ON SL.SetMenuLevelID = CT.SetMenuLevelID
    GROUP BY
        CT.MenuItemID,
        SL.SetMenuLevelID,
        SML.MaxQuantity,
        CT.SetMenuItemID;


    /* =========================================================
       Remove modifiers which are not Main Menu items
       ========================================================= */

    DELETE FROM #TempModifier
    WHERE ModifierMenuCode NOT IN
    (
        SELECT ItemCode
        FROM #TempMainMenu
    );


    /* =========================================================
       Modifier Main Item - MenuItemWiseModifier
       ========================================================= */

    INSERT INTO #TempModifierMainItem
    (
        MainMenuCode,
        ActionID
    )
    SELECT
        CT.MainMenuCode,
        CT.ActionID
    FROM MenuItemWiseModifier CT
    INNER JOIN #TempMainMenu MM
        ON CT.MainMenuCode = MM.ItemCode
    GROUP BY
        CT.MainMenuCode,
        CT.ActionID;


    /* =========================================================
       Modifier Main Item - Set Menu
       ========================================================= */

    INSERT INTO #TempModifierMainItem
    (
        MainMenuCode,
        ActionID
    )
    SELECT
        CT.SetMenuItemID AS MainMenuCode,
        SL.SetMenuLevelID AS ActionID
    FROM POS_SetMenuItemDetails CT
    INNER JOIN #TempMainMenu MM
        ON CT.SetMenuItemID = MM.ItemCode
    INNER JOIN POS_SetMenuLevels SL
        ON SL.SetMenuLevelID = CT.SetMenuLevelID
    GROUP BY
        CT.SetMenuItemID,
        SL.SetMenuLevelID;


    /* =========================================================
       Action Buttons
       ========================================================= */

    INSERT INTO #TempActionButton
    (
        ID,
        Name,
        MaxQty,
        MenuCode
    )
    SELECT
        AB.ID,
        AB.DisplayName AS Name,
        1,
        TAB.MenuCode
    FROM #TempModifier TAB
    INNER JOIN ActionButtons AB
        ON TAB.ActionID = AB.ID
    GROUP BY
        AB.ID,
        AB.DisplayName,
        TAB.MenuCode;


    /* =========================================================
       Build JSON
       ========================================================= */

    INSERT INTO #JsonResult
    (
        JsonData
    )
    SELECT
        CAST
        (
            (
                SELECT
                    'Main Menu' AS [name],

                    (
                        SELECT
                            CT.Description AS [name],

                            (
                                SELECT

                                    CONCAT('http://124.43.11.169:8089/ItemImages/',ISNULL((SELECT TOP(1) [ImageName] FROM [Categlog_vrV2].[dbo].[POS_Image] WHERE [Code] = MM.ItemCode AND [DataType] = 'ITM' AND [PropertyId] = @PropertyId),''))
                                        AS [image_url],

                                    MM.ItemCode AS [external_id],

                                    MM.Description AS [name],

                                    MM.FullName AS [description],

                                    ISNULL
                                    (
                                        (
                                            SELECT TOP 1
                                                Price * 100
                                            FROM POS_OutletWiseMenuItemPrice
                                            WHERE OutletCode = @Outlet
                                              AND PropertyId = @PropertyId
                                              AND MenuItemCode = MM.ItemCode
                                              AND PriceTypeID = 1
                                        ),
                                        0
                                    ) AS [price_cents],

                                    CAST(0 AS BIT) AS [sold_out],

                                    ISNULL
                                    (
                                        (
                                            SELECT

                                                CONCAT
                                                (
                                                    'MOD_',
                                                    AB.ID
                                                ) AS [external_id],

                                                AB.Name AS [name],

                                                (
                                                    SELECT

                                                        CONCAT
                                                        (
                                                            'OPT_',
                                                            OPT.ItemCode
                                                        ) AS [external_id],

                                                        OPT.Description AS [value],

                                                        0 AS [price_increase_cents],

                                                        CAST(0 AS BIT) AS [sold_out]

                                                    FROM #TempMainMenu OPT

                                                    INNER JOIN #TempModifier M
                                                        ON M.ModifierMenuCode = OPT.ItemCode

                                                    WHERE M.ActionID = AB.ID
                                                      AND M.MenuCode = MM.ItemCode

                                                    FOR JSON PATH
                                                ) AS [options]

                                            FROM #TempActionButton AB

                                            WHERE AB.MenuCode = MM.ItemCode

                                            FOR JSON PATH
                                        ),
                                        '[]'
                                    ) AS [modifiers]

                                FROM #TempMainMenu MM

                                WHERE MM.Category = CT.Code

                                FOR JSON PATH
                            ) AS [items]

                        FROM Category CT

                        WHERE CT.PropertyId = @PropertyId

                          AND CT.Code IN
                          (
                              SELECT DISTINCT
                                  Category
                              FROM #TempMainMenu
                          )

                        ORDER BY CT.Seq

                        FOR JSON PATH

                    ) AS [categories]

                FOR JSON PATH, ROOT('menus')
            )
            AS NVARCHAR(MAX)
        );


    /* =========================================================
       Return Complete JSON
       ========================================================= */

    SELECT
        JsonData
    FROM #JsonResult;


    /* =========================================================
       Cleanup
       ========================================================= */

    DROP TABLE #JsonResult;
    DROP TABLE #JsonData;
    DROP TABLE #TempMainMenu;
    DROP TABLE #TempModifier;
    DROP TABLE #TempModifierMainItem;
    DROP TABLE #TempActionButton;

END

GO

