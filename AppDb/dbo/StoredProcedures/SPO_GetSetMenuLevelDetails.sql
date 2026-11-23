-- EXEC SPO_GetSetMenuLevelDetails '1000',1
-- =============================================
-- Author:		Ravindu
-- Create date: 2026-03-12
-- Description:	Get SetMenu Level Details in JSON Format
-- =============================================
CREATE   PROCEDURE [dbo].[SPO_GetSetMenuLevelDetails] 
	@ItemCode VARCHAR(MAX),
    @PropertyId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        mmParent.Id                  AS ItemId,
        mmParent.ItemCode            AS ItemCode,
        mmParent.Description         AS ItemName,
        mmParent.Price               AS ItemPrice,
        (
            SELECT 
                sml.SetMenuLevelID,
                sml.Description      AS LevelName,
                sld.SortOrder        AS LevelSortOrder,
                sld.LevelQuantity,
                sld.MaxQuantity,
                sld.IsOptional,
                (
                    SELECT 
                        smid.LevelItemID,
                        smid.MenuItemID,
                        mm.ItemCode      AS ItemCode,
                        mm.Description   AS ItemName,
                        mm.Price         AS ItemPrice,
                        mm.Active        AS IsActive,
                        smid.AddRate,
                        smid.SortOrder
                    FROM POS_SetMenuItemDetails smid
                    INNER JOIN MainMenu mm
                        ON mm.ItemCode     = smid.MenuItemID
                        AND mm.PropertyId  = @PropertyId
                    WHERE 
                        smid.SetMenuItemID  = mmParent.ItemCode
                        AND smid.SetMenuLevelID = sml.SetMenuLevelID
                        AND smid.IsActive   = 1
                        AND smid.PropertyId = @PropertyId
                    ORDER BY smid.SortOrder
                    FOR JSON PATH
                ) AS LevelItems

            FROM POS_SetMenuLevelDetails sld
            INNER JOIN POS_SetMenuLevels sml
                ON sml.SetMenuLevelID  = sld.SetMenuLevelID
                AND sml.IsActive       = 1
                AND sml.PropertyId     = @PropertyId
            WHERE 
                sld.SetMenuItemID  = @ItemCode
                AND sld.IsActive   = 1
                AND sld.PropertyId = @PropertyId
            ORDER BY sld.SortOrder
            FOR JSON PATH
        ) AS Levels

    FROM MainMenu mmParent
    WHERE 
        mmParent.ItemCode         = @ItemCode
        AND mmParent.PropertyId = @PropertyId

    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER;

END

GO

