--change name to Dayend_SP_CheckInventoryRecipeIssuesAccountMapping_OutletWise
CREATE PROCEDURE [dbo].[Dayend_SP_CheckInventoryRecipeIssuesAccountMapping_OutletWise_PrinterWise]
    @PropertyId INT,
    @HotelDate DATE,
    @Outlet VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BlockCode VARCHAR(5) = 'KTI';   -- dont change block code
    DECLARE @BlockCode2 VARCHAR(5) = 'GRN';  -- dont change block code
    DECLARE @GLCompCode VARCHAR(5);

    SELECT @GLCompCode = GLCOMPCODE
    FROM Companies
    WHERE CompanyID = @PropertyId;


    /* ============================================================
       TEMP TABLE
       ============================================================ */

    CREATE TABLE #AccountMappingIssues
    (
        Id INT IDENTITY(1,1),
        AccMapStatus VARCHAR(50),
        Location VARCHAR(200),
        DepartMentName VARCHAR(200),
        CategoryName VARCHAR(200),
        SubCategory1 VARCHAR(200),
        SubCategory2 VARCHAR(200),
        BlockCode VARCHAR(5),
        AccCode VARCHAR(100)
    );


    /* ============================================================
       INSERT KTI DATA
       ============================================================ */

    INSERT INTO #AccountMappingIssues
    (
        AccMapStatus,
        Location,
        DepartMentName,
        CategoryName,
        SubCategory1,
        SubCategory2,
        BlockCode,
        AccCode
    )
    SELECT
        NULL AS AccMapStatus,
        L.Name AS Location,
        DD.Name AS DepartMentName,
        C.Name AS CategoryName,
        SC1.Name AS SubCategory1,
        SC2.Description AS SubCategory2,
        @BlockCode AS BlockCode,
        GLM.AccCode

    FROM RecipeDetails AS RD

    INNER JOIN RecipeHeader AS RH
        ON RD.RecipeCode = RH.RecipeCode
        AND RD.PropertyId = RH.PropertyId

    INNER JOIN ItemBreakDown AS IB
        ON RH.RecipeCode = IB.RecipeCode
        AND IB.PropertyId = RH.PropertyId

    INNER JOIN BillTrans AS BT
        ON IB.MainMenuCode = BT.MainMenuCode
        AND BT.PropertyId = IB.PropertyId

    INNER JOIN ItemWisePrinters AS IP
        ON BT.MainMenuCode = IP.MainMenuCode
        AND BT.PropertyId = IP.PropertyId

    INNER JOIN PrinterType AS LR
        ON BT.Outlet = LR.OutletID
        AND IP.PrinterCode = LR.Code

    INNER JOIN StockItemDetails AS SD
        ON RD.StockItemCode = SD.StockItemHeaderID
        AND SD.PropertyID = BT.PropertyId
        AND SD.LocationID = LR.StockLocationID

    INNER JOIN StockItemHeaders AS SH
        ON SD.StockItemHeaderID = SH.Id

    INNER JOIN Categories AS C
        ON SH.CategoryID = C.Id

    INNER JOIN SubCategories AS SC1
        ON SH.SubCategoryID = SC1.Id

    INNER JOIN SubCategories02 AS SC2
        ON SH.SubCategory2ID = SC2.Id

    INNER JOIN Departments AS DD
        ON DD.Id = LR.DepartmentID

    INNER JOIN Locations AS L
        ON L.Id = LR.StockLocationID

    LEFT JOIN eFinancials_Accounting..Destinity_GLIntegrationAccountMapping AS GLM
        ON GLM.Level1 = DD.Code
        AND GLM.Level2 = C.Code
        AND GLM.Level3 = SC1.Code
        AND GLM.Level4 = SC2.Code
        AND GLM.BlockCode = @BlockCode
        AND GLM.GLCompCode = @GLCompCode

    WHERE
        BT.PropertyId = @PropertyId
        AND BT.OrderDate >= @HotelDate
        AND BT.OrderDate < DATEADD(DAY, 1, @HotelDate)
        AND LR.OutletID = @Outlet

    GROUP BY
        L.Id,
        L.Code,
        L.Name,

        DD.Id,
        DD.Code,
        DD.Name,

        C.Id,
        C.Code,
        C.Name,

        SC1.Id,
        SC1.Code,
        SC1.Name,

        SC2.Id,
        SC2.Code,
        SC2.Description,

        GLM.AccCode;


    /* ============================================================
       INSERT GRN DATA
       ============================================================ */

    INSERT INTO #AccountMappingIssues
    (
        AccMapStatus,
        Location,
        DepartMentName,
        CategoryName,
        SubCategory1,
        SubCategory2,
        BlockCode,
        AccCode
    )
    SELECT
        NULL AS AccMapStatus,
        L.Name AS Location,
        '' AS DepartMentName,
        C.Name AS CategoryName,
        '' AS SubCategory1,
        '' AS SubCategory2,
        @BlockCode2 AS BlockCode,
        GLM.AccCode

    FROM RecipeDetails AS RD

    INNER JOIN RecipeHeader AS RH
        ON RD.RecipeCode = RH.RecipeCode
        AND RD.PropertyId = RH.PropertyId

    INNER JOIN ItemBreakDown AS IB
        ON RH.RecipeCode = IB.RecipeCode
        AND IB.PropertyId = RH.PropertyId

    INNER JOIN BillTrans AS BT
        ON IB.MainMenuCode = BT.MainMenuCode
        AND BT.PropertyId = IB.PropertyId

    INNER JOIN ItemWisePrinters AS IP
        ON BT.MainMenuCode = IP.MainMenuCode
        AND BT.PropertyId = IP.PropertyId

    INNER JOIN PrinterType AS LR
        ON BT.Outlet = LR.OutletID
        AND IP.PrinterCode = LR.Code

    INNER JOIN StockItemDetails AS SD
        ON RD.StockItemCode = SD.StockItemHeaderID
        AND SD.PropertyID = BT.PropertyId
        AND SD.LocationID = LR.StockLocationID

    INNER JOIN StockItemHeaders AS SH
        ON SD.StockItemHeaderID = SH.Id

    INNER JOIN Categories AS C
        ON SH.CategoryID = C.Id

    INNER JOIN SubCategories AS SC1
        ON SH.SubCategoryID = SC1.Id

    INNER JOIN SubCategories02 AS SC2
        ON SH.SubCategory2ID = SC2.Id

    INNER JOIN Departments AS DD
        ON DD.Id = LR.DepartmentID

    INNER JOIN Locations AS L
        ON L.Id = LR.StockLocationID

    LEFT JOIN eFinancials_Accounting..Destinity_GLIntegrationAccountMapping AS GLM
        ON GLM.Level1 = L.Code
        AND GLM.Level2 = C.Code
        AND GLM.BlockCode = @BlockCode2
        AND GLM.GLCompCode = @GLCompCode

    WHERE
        BT.PropertyId = @PropertyId
        AND BT.OrderDate >= @HotelDate
        AND BT.OrderDate < DATEADD(DAY, 1, @HotelDate)
        AND LR.OutletID = @Outlet

    GROUP BY
        L.Id,
        L.Code,
        L.Name,

        C.Id,
        C.Code,
        C.Name,

        GLM.AccCode;


    /* ============================================================
       UPDATE ACCOUNT MAPPING STATUS
       AFTER ALL DATA HAS BEEN INSERTED
       ============================================================ */

    UPDATE #AccountMappingIssues
    SET AccMapStatus =
        CASE
            WHEN AccCode IS NULL THEN 'Not Account Map'
            ELSE 'Account Map'
        END;


    /* ============================================================
       ONE FINAL SELECT
       ============================================================ */

    SELECT
        AccMapStatus,
        Location,
        DepartMentName,
        CategoryName,
        SubCategory1,
        SubCategory2,
        BlockCode
    FROM #AccountMappingIssues
	WHERE AccMapStatus = 'Not Account Map'
    ORDER BY
        CASE
            WHEN AccMapStatus = 'Not Account Map' THEN 0
            ELSE 1
        END,
        BlockCode,
        Location,
        DepartMentName,
        CategoryName,
        SubCategory1,
        SubCategory2;


    DROP TABLE #AccountMappingIssues;

END

GO

