-- =============================================
-- Author : Tharuka Sachintha
-- Create date: 2026-10-09
-- Description: Day End Validation Modes -  ALTERS the EXISTING dbo.SP_GetDayEndValidationModes, the Day End
--              Validation Mode dropdown of the Locations master screen

-- EXEC dbo.SP_GetDayEndValidationModes

-- =============================================

CREATE   PROCEDURE [dbo].[SP_GetDayEndValidationModes]
AS
BEGIN

    SET NOCOUNT ON;

    SELECT  Id                          AS id,
            LTRIM(RTRIM(Name))          AS text,
            LTRIM(RTRIM(Code))          AS code
    FROM    dbo.DayEnd_ValidationModes
    --WHERE   Code IS NOT NULL
    --        AND LTRIM(RTRIM(Code)) <> N''
    --Changed 2026-10-09 - Day End Validation Modes: only active modes are offered for locations
    WHERE   Code IS NOT NULL
            AND LTRIM(RTRIM(Code)) <> N''
            AND ISNULL(IsActive, 1) = 1
    --end 2026-10-09
    ORDER BY Id;

END

GO

