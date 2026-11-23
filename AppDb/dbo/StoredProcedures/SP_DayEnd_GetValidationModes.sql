-- =============================================
-- Author : Tharuka Sachintha
-- Create date: 2026-10-09
-- Description: Day End Validation Modes Saved Modes list of the Day End Validation Modes screen

-- EXEC dbo.SP_DayEnd_GetValidationModes 1
-- =============================================

CREATE   PROCEDURE dbo.SP_DayEnd_GetValidationModes
    @PropertyID INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  vm.Id,
            LTRIM(RTRIM(vm.Code))           AS Code,
            LTRIM(RTRIM(vm.Name))           AS Name,
            ISNULL(vm.IsActive, 1)          AS IsActive,
            ISNULL(vm.IsSystem, 0)          AS IsSystem,
            (SELECT COUNT(*)
             FROM   dbo.DayEnd_ValidationModeDetails d
                    INNER JOIN dbo.DayEnd_ValidationChecks c ON c.Id = d.ValidationCheckID AND c.IsActive = 1
             WHERE  d.ValidationModeID = vm.Id
                    AND d.PropertyID = @PropertyID)                         AS CheckCount,
            (SELECT COUNT(*)
             FROM   dbo.Locations l
             WHERE  l.PropertyId = @PropertyID
                    AND LTRIM(RTRIM(l.DayEndValidationMode)) = LTRIM(RTRIM(vm.Code))) AS LocationCount
    FROM    dbo.DayEnd_ValidationModes vm
    WHERE   vm.Code IS NOT NULL
            AND LTRIM(RTRIM(vm.Code)) <> N''
    ORDER BY ISNULL(vm.IsSystem, 0) DESC, vm.Id;
END

GO

