-- ============================================================================
-- 56_ALTER_SP_CheckGLMappingForItems_RCO_GRN.sql
--
-- Extends SP_CheckGLMappingForItems so that when checking reconciliation (RCO),
-- it runs a second pass for GRN and returns both sets of GL mapping results.
-- Reconciliation transactions can generate both negative adjustments (RCO) and
-- positive adjustments (GRN), so both GL mapping blocks are verified.
--
-- Result sets returned when @BLOCKCODE = 'RCO':
--   1: Header (RCO)
--   2: Unmapped combinations (RCO)
--   3: Header (GRN)
--   4: Unmapped combinations (GRN)
-- ============================================================================

CREATE   PROCEDURE [dbo].[SP_CheckGLMappingForItems]
(
    @PropertyID      INT,
    @LocationID      INT,
    @TransactionType CHAR(2),
    @XMLDetails      XML,
    @DepartmentID    INT = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        IF (@TransactionType = 'RI')
            SET @TransactionType = 'IN';

        DECLARE @GLCOMPCODE       VARCHAR(10)  = '',
                @LocationCode     VARCHAR(120) = '',
                @DepartmentCode   VARCHAR(120) = '',
                @DepartmentName   VARCHAR(100) = '',
                @BLOCKCODEID      INT          = 0,
                @BLOCKCODE        VARCHAR(4)   = '',
                @BlockDescription VARCHAR(50)  = '',
                @NoOfLevels       INT          = 0,
                @L1Desc           VARCHAR(20)  = '',
                @L2Desc           VARCHAR(20)  = '',
                @L3Desc           VARCHAR(20)  = '',
                @L4Desc           VARCHAR(20)  = '',
                @Message          VARCHAR(500) = '',
                @LocationName     VARCHAR(100) = '',
                @CategoryName     VARCHAR(100) = '';

        -- 2026-09-03: the franchise location being invoiced, for GL block 'INV'.
        DECLARE @InvoiceLocationCode VARCHAR(120) = '',
                @InvoiceLocationName VARCHAR(100) = '';

        -- Shared lookups (same for every pass)
        SELECT  @GLCOMPCODE   = C.CODE,
                @LocationCode = L.Code,
                @LocationName = L.Name
        FROM    Companies C
        INNER JOIN Locations L ON L.CompanyID = C.CompanyID
        WHERE   C.CompanyID = @PropertyID
          AND   L.ID        = @LocationID;

        SELECT @DepartmentCode = ISNULL(CODE, ''), @DepartmentName = ISNULL(Name, '')
        FROM   Departments
        WHERE  ID = @DepartmentID;

        SET @DepartmentCode = ISNULL(@DepartmentCode, '');
        SET @DepartmentName = ISNULL(@DepartmentName, '');

        SELECT TOP 1 @InvoiceLocationCode = ISNULL(Code, ''),
                     @InvoiceLocationName = ISNULL(Name, '')
        FROM   Locations
        WHERE  DepartmentID = @DepartmentID
        ORDER BY Id;

        SET @InvoiceLocationCode = ISNULL(@InvoiceLocationCode, '');
        SET @InvoiceLocationName = ISNULL(@InvoiceLocationName, '');

        SELECT DISTINCT t.x.value('(StockItemID)[1]', 'INT') AS StockItemID
        INTO   #Items
        FROM   @XMLDetails.nodes('/*/*') AS t(x)
        WHERE  t.x.exist('StockItemID') = 1
          AND  t.x.value('(StockItemID)[1]', 'INT') IS NOT NULL;

        DECLARE @TotalItems INT = (SELECT COUNT(*) FROM #Items);

        -- Pass 1 = block of the transaction type. Pass 2 = GRN, only if pass 1 resolved to RCO.
        DECLARE @Pass       INT = 1,
                @Passes     INT = 1,
                @CheckedFor VARCHAR(10),
                @UnmappedCount INT;

        WHILE @Pass <= @Passes
        BEGIN
            -- reset per-pass state
            SELECT @BLOCKCODEID = 0, @BLOCKCODE = '', @BlockDescription = '', @NoOfLevels = 0,
                   @L1Desc = '', @L2Desc = '', @L3Desc = '', @L4Desc = '', @Message = '';

            IF @Pass = 1
            BEGIN
                SET @CheckedFor = @TransactionType;

                SELECT @BLOCKCODEID = GLBlockID
                FROM   TransactionTypes
                WHERE  Code = @TransactionType;
            END
            ELSE
            BEGIN
                SET @CheckedFor = 'GRN';

                SELECT @BLOCKCODEID = ID
                FROM   [eFinancials_Accounting].[dbo].[Destinity_GLIntegrationAccountMappingBlocks]
                WHERE  BlockCode = 'GRN';
            END

            SELECT  @BLOCKCODE        = BlockCode,
                    @BlockDescription = ISNULL(BlockDescription, ''),
                    @NoOfLevels       = ISNULL(NoOfLevels, 0),
                    @L1Desc           = ISNULL(Level1Description, ''),
                    @L2Desc           = ISNULL(Level2Description, ''),
                    @L3Desc           = ISNULL(Level3Description, ''),
                    @L4Desc           = ISNULL(Level4Description, '')
            FROM    [eFinancials_Accounting].[dbo].[Destinity_GLIntegrationAccountMappingBlocks]
            WHERE   ID = @BLOCKCODEID;

            SET @BLOCKCODE = ISNULL(@BLOCKCODE, '');

            -- RCO also needs the GRN mapping shown
            IF @Pass = 1 AND @BLOCKCODE = 'RCO'
                SET @Passes = 2;

            CREATE TABLE #ItemLevels
            (
                StockItemID INT,
                ItemName    VARCHAR(255) NOT NULL DEFAULT '',
                Location    VARCHAR(100) NOT NULL DEFAULT '',
                Category    VARCHAR(100) NOT NULL DEFAULT '',
                Level1      VARCHAR(50)  NOT NULL DEFAULT '',
                Level2      VARCHAR(50)  NOT NULL DEFAULT '',
                Level3      VARCHAR(50)  NOT NULL DEFAULT '',
                Level4      VARCHAR(50)  NOT NULL DEFAULT ''
            );

            IF @BLOCKCODE IN ('GRN', 'SRN', 'DMN', 'RCO')
            BEGIN
                INSERT INTO #ItemLevels (StockItemID, ItemName, Location, Category, Level1, Level2, Level3, Level4)
                SELECT  I.StockItemID,
                        ISNULL(SIH.Name, ''),
                        @LocationName,
                        ISNULL(C.Name, ''),
                        @LocationCode,
                        ISNULL(C.Code, ''),
                        '',
                        ''
                FROM    #Items I
                LEFT JOIN StockItemHeaders SIH ON SIH.Id = I.StockItemID
                LEFT JOIN Categories C
                       ON C.Id = SIH.CategoryID
                      AND EXISTS (SELECT 1
                                  FROM   Locations L
                                  INNER JOIN StockItemDetails D
                                          ON D.CompanyID         = L.CompanyID
                                         AND D.StockItemHeaderID = SIH.Id
                                         AND D.LocationID        = L.Id
                                  INNER JOIN Companies P ON P.CompanyID = L.CompanyID
                                  WHERE  P.Code = @GLCOMPCODE
                                    AND  L.Code = @LocationCode);
            END
            ELSE IF @BLOCKCODE IN ('ISN', 'ISR', 'KTI')
            BEGIN
                INSERT INTO #ItemLevels (StockItemID, ItemName, Location, Category, Level1, Level2, Level3, Level4)
                SELECT  I.StockItemID,
                        ISNULL(SIH.Name, ''),
                        @DepartmentName,
                        ISNULL(C.Name, ''),
                        @DepartmentCode,
                        ISNULL(C.Code, ''),
                        ISNULL(SC.Code, ''),
                        ISNULL(SSC.Code, '')
                FROM    #Items I
                LEFT JOIN StockItemHeaders SIH ON SIH.Id  = I.StockItemID
                LEFT JOIN Categories       C   ON C.Id    = SIH.CategoryID
                LEFT JOIN SubCategories    SC  ON SC.Id   = SIH.SubCategoryID
                LEFT JOIN SubCategories02  SSC ON SSC.Id  = SIH.SubCategory2ID;
            END
            ELSE IF @BLOCKCODE = 'INV'
            BEGIN
                INSERT INTO #ItemLevels (StockItemID, ItemName, Location, Category, Level1, Level2, Level3, Level4)
                SELECT  I.StockItemID,
                        ISNULL(SIH.Name, ''),
                        @InvoiceLocationName,
                        ISNULL(C.Name, ''),
                        @InvoiceLocationCode,
                        ISNULL(C.Code, ''),
                        ISNULL(SC.Code, ''),
                        ''
                FROM    #Items I
                LEFT JOIN StockItemHeaders SIH ON SIH.Id = I.StockItemID
                LEFT JOIN Categories       C   ON C.Id   = SIH.CategoryID
                LEFT JOIN SubCategories    SC  ON SC.Id  = SIH.SubCategoryID;

                IF @InvoiceLocationCode = ''
                    SET @Message = 'No franchise location is linked to the selected department, so no INV mapping can match. Check Locations.DepartmentID for this franchise.';
            END
            ELSE
            BEGIN
                SET @Message =
                    CASE
                        WHEN @BLOCKCODE = ''
                            THEN 'No GL block is configured for transaction type ''' + LTRIM(RTRIM(@CheckedFor)) + '''.'
                        ELSE 'GL block ''' + @BLOCKCODE + ''' is not supported by this mapping check.'
                    END;
            END

            SET @UnmappedCount =
            (
                SELECT COUNT(*)
                FROM (
                    SELECT DISTINCT IL.Level1, IL.Level2, IL.Level3, IL.Level4
                    FROM   #ItemLevels IL
                    WHERE  NOT EXISTS (
                               SELECT 1
                               FROM   [eFinancials_Accounting].[dbo].[Destinity_GLIntegrationAccountMapping] M
                               WHERE  M.BlockCode          = @BLOCKCODE
                                 AND  ISNULL(M.Level1, '') = IL.Level1
                                 AND  ISNULL(M.Level2, '') = IL.Level2
                                 AND  ISNULL(M.Level3, '') = IL.Level3
                                 AND  ISNULL(M.Level4, '') = IL.Level4
                                 AND  M.GLCompCode         = @GLCOMPCODE)
                ) q
            );

            -- Header result set (pass 1 = set 1, pass 2 = set 3)
            SELECT  @BLOCKCODE           AS BlockCode,
                    @BlockDescription    AS BlockDescription,
                    @NoOfLevels          AS NoOfLevels,
                    @L1Desc              AS Level1Description,
                    @L2Desc              AS Level2Description,
                    @L3Desc              AS Level3Description,
                    @L4Desc              AS Level4Description,
                    @GLCOMPCODE          AS GLCompCode,
                    @LocationCode        AS LocationCode,
                    @LocationName        AS LocationName,
                    @DepartmentName      AS DepartmentName,
                    @DepartmentCode      AS DepartmentCode,
                    @InvoiceLocationCode AS InvoiceLocationCode,
                    @InvoiceLocationName AS InvoiceLocationName,
                    @TotalItems          AS TotalItems,
                    @UnmappedCount       AS UnmappedCount,
                    @Message             AS Message;

            -- Unmapped details result set (pass 1 = set 2, pass 2 = set 4)
            ;WITH Unmapped AS
            (
                SELECT  (IL.Level1 + ' - ' + IL.Location) AS Level1,
                        (IL.Level2 + ' - ' + IL.Category) AS Level2,
                        IL.Level3, IL.Level4, IL.ItemName,
                        ROW_NUMBER() OVER (PARTITION BY IL.Level1, IL.Level2, IL.Level3, IL.Level4
                                           ORDER BY IL.ItemName) AS rn
                FROM    #ItemLevels IL
                WHERE   NOT EXISTS (
                            SELECT 1
                            FROM   [eFinancials_Accounting].[dbo].[Destinity_GLIntegrationAccountMapping] M
                            WHERE  M.BlockCode          = @BLOCKCODE
                              AND  ISNULL(M.Level1, '') = IL.Level1
                              AND  ISNULL(M.Level2, '') = IL.Level2
                              AND  ISNULL(M.Level3, '') = IL.Level3
                              AND  ISNULL(M.Level4, '') = IL.Level4
                              AND  M.GLCompCode         = @GLCOMPCODE)
            )
            SELECT  U.Level1, U.Level2, U.Level3, U.Level4,
                    COUNT(*) AS ItemCount,
                    STRING_AGG(CASE WHEN U.rn <= 5 THEN U.ItemName END, ', ')
                        WITHIN GROUP (ORDER BY U.rn) AS ItemNames
            FROM    Unmapped U
            GROUP BY U.Level1, U.Level2, U.Level3, U.Level4
            ORDER BY U.Level1, U.Level2, U.Level3, U.Level4;

            DROP TABLE #ItemLevels;
            SET @Pass += 1;
        END

        DROP TABLE #Items;

    END TRY
    BEGIN CATCH
        DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrSev INT            = ERROR_SEVERITY();
        DECLARE @ErrSta INT            = ERROR_STATE();
        RAISERROR (@ErrMsg, @ErrSev, @ErrSta);
    END CATCH
END

GO

