-- =============================================
-- Author : Tharuka Sachintha
-- Create date: 2026-10-09
-- Description: Day End Validation Modes - Item templates for the Reconciliation / Spot Check dropdowns of the
--              Day End Validation Modes screen

-- EXEC dbo.SP_DayEnd_GetItemTemplates 1

-- =============================================

CREATE   PROCEDURE dbo.SP_DayEnd_GetItemTemplates
    @PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  h.TemplateHeaderID,
            LTRIM(RTRIM(h.Name))    AS Name,
            ISNULL(cnt.ItemCount, 0) AS ItemCount,
            names.ItemNames
                + CASE WHEN ISNULL(cnt.ItemCount, 0) > 20 THEN N', ...' ELSE N'' END AS ItemNames
    FROM    dbo.RequestTemplateHeader h
            OUTER APPLY (SELECT COUNT(*) AS ItemCount
                         FROM   dbo.RequestTemplateDetails d
                         WHERE  d.TemplateHeaderID = h.TemplateHeaderID) cnt
            OUTER APPLY (SELECT STRING_AGG(CONVERT(NVARCHAR(MAX), x.Name), N', ')
                                WITHIN GROUP (ORDER BY x.Name) AS ItemNames
                         FROM   (SELECT TOP (20) LTRIM(RTRIM(s.Name)) AS Name
                                 FROM   dbo.RequestTemplateDetails d
                                        INNER JOIN dbo.StockItemHeaders s ON s.Id = d.StockItemHeaderID
                                 WHERE  d.TemplateHeaderID = h.TemplateHeaderID
                                 ORDER BY s.Name) x) names
    WHERE   h.PropertyId = @PropertyID
            AND h.IsActive = 1
    ORDER BY h.Name;
END

GO

