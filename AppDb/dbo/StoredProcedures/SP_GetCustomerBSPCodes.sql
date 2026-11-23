
-- =============================================
-- Created By : Tharuka Sachintha
-- Date: 2026-09-11
-- Description: Customer BSP codes for the Departments screen, sourced from
--              eFinancials_Accounting.dbo.Destinity_AR_SelectBSPasSuppliersDebtor.
--
--              The synonym follows the existing convention in this DB (same name as
--              the target, e.g. Destinity_AP_CreditorTypes). If eFinancials lives under
--              a different database name on a given site, only the synonym changes.
-- =============================================

CREATE   PROCEDURE dbo.SP_GetCustomerBSPCodes
AS
BEGIN
    SET NOCOUNT ON;

    CREATE TABLE #BSPCodes
    (
        BSPCode VARCHAR(20),
        SupName VARCHAR(500),
        Tax     INT
    );

    -- @All is declared by the source procedure but not used in its body; 'Y' is passed
    -- as the documented call.
    INSERT INTO #BSPCodes (BSPCode, SupName, Tax)
    EXEC dbo.Destinity_AR_SelectBSPasSuppliersDebtor @All = 'Y';

    SELECT  RTRIM(BSPCode)              AS BSPCode,
            LTRIM(RTRIM(SupName))       AS SupName,
            CAST(Tax AS BIT)            AS Tax
    FROM    #BSPCodes
    WHERE   NULLIF(LTRIM(RTRIM(BSPCode)), '') IS NOT NULL
    ORDER BY LTRIM(RTRIM(SupName));

    DROP TABLE #BSPCodes;
END

GO

