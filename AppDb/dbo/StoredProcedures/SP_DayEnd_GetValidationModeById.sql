-- =============================================
-- Author : Tharuka Sachintha
-- Create date: 2026-10-09
-- Description: Day End Validation Modes - One mode for the form of the Day End Validation Modes screen


-- EXEC dbo.SP_DayEnd_GetValidationModeById 2, 1
-- EXEC dbo.SP_DayEnd_GetValidationModeById 0, 1
-- =============================================

CREATE   PROCEDURE dbo.SP_DayEnd_GetValidationModeById
    @Id         INT,
    @PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. header
    SELECT  vm.Id,
            LTRIM(RTRIM(vm.Code))   AS Code,
            LTRIM(RTRIM(vm.Name))   AS Name,
            ISNULL(vm.IsActive, 1)  AS IsActive,
            ISNULL(vm.IsSystem, 0)  AS IsSystem,
            (SELECT COUNT(*)
             FROM   dbo.Locations l
             WHERE  l.PropertyId = @PropertyID
                    AND LTRIM(RTRIM(l.DayEndValidationMode)) = LTRIM(RTRIM(vm.Code))) AS LocationCount
    FROM    dbo.DayEnd_ValidationModes vm
    WHERE   vm.Id = @Id
            AND @Id > 0;

    -- 2. detail: every active transaction type
    SELECT  c.Id                    AS ValidationCheckID,
            c.Code                  AS CheckCode,
            c.Name                  AS CheckName,
            c.TransactionTypes,
            c.ConfigType,
            c.Description,
            c.SortOrder,
            CAST(CASE WHEN d.Id IS NULL THEN 0 ELSE 1 END AS BIT) AS IsSelected,
            d.ItemTemplateID
    FROM    dbo.DayEnd_ValidationChecks c
            LEFT JOIN dbo.DayEnd_ValidationModeDetails d
                   ON d.ValidationCheckID = c.Id
                  AND d.ValidationModeID = @Id
                  AND d.PropertyID = @PropertyID
    WHERE   c.IsActive = 1
    ORDER BY c.SortOrder, c.Id;
END

GO

