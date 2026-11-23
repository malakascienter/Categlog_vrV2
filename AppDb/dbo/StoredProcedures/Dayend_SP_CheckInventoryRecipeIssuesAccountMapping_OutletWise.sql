
CREATE PROCEDURE [dbo].[Dayend_SP_CheckInventoryRecipeIssuesAccountMapping_OutletWise]
    @PropertyId INT,
    @HotelDate DATE,
    @Outlet VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;

    --/* ============================================================
    --   VARIABLES
    --   ============================================================ */

    --DECLARE @BlockCode VARCHAR(5) = 'KTI';   -- DO NOT CHANGE
    --DECLARE @BlockCode2 VARCHAR(5) = 'GRN';  -- DO NOT CHANGE
    --DECLARE @GLCompCode VARCHAR(5);


    --/* ============================================================
    --   GET GL COMPANY CODE
    --   ============================================================ */

    --SELECT @GLCompCode = GLCOMPCODE
    --FROM Companies
    --WHERE CompanyID = @PropertyId;


    --/* ============================================================
    --   TEMP TABLE
    --   ============================================================ */

    --CREATE TABLE #AccountMappingIssues
    --(
    --    Id INT IDENTITY(1,1),

    --    AccMapStatus VARCHAR(50),

    --    Location VARCHAR(500),

    --    DepartMentName VARCHAR(500),

    --    CategoryName VARCHAR(500),

    --    SubCategory1 VARCHAR(500),

    --    SubCategory2 VARCHAR(500),

    --    BlockCode VARCHAR(5),

    --    AccCode VARCHAR(100)
    --);


    --/* ============================================================
    --   KTI BLOCK CODE
       
    --   Account Mapping:
       
    --   Level1 = Department
    --   Level2 = Category
    --   Level3 = SubCategory1
    --   Level4 = SubCategory2
    --   ============================================================ */

    --INSERT INTO #AccountMappingIssues
    --(
    --    AccMapStatus,
    --    Location,
    --    DepartMentName,
    --    CategoryName,
    --    SubCategory1,
    --    SubCategory2,
    --    BlockCode,
    --    AccCode
    --)
    --SELECT
    --    NULL AS AccMapStatus,

    --    L.Name AS Location,

    --    DD.Name AS DepartMentName,

    --    C.Name AS CategoryName,

    --    SC1.Name AS SubCategory1,

    --    SC2.Description AS SubCategory2,

    --    @BlockCode AS BlockCode,

    --    GLM.AccCode

    --FROM RecipeDetails AS RD

    --INNER JOIN RecipeHeader AS RH
    --    ON RD.RecipeCode = RH.RecipeCode
    --    AND RD.PropertyId = RH.PropertyId

    --INNER JOIN ItemBreakDown AS IB
    --    ON RH.RecipeCode = IB.RecipeCode
    --    AND IB.PropertyId = RH.PropertyId

    --INNER JOIN BillTrans AS BT
    --    ON IB.MainMenuCode = BT.MainMenuCode
    --    AND BT.PropertyId = IB.PropertyId

    --INNER JOIN Location_Ref AS LR
    --    ON BT.Outlet = LR.Code
    --    AND LR.PropertyId = BT.PropertyId

    --INNER JOIN StockItemDetails AS SD
    --    ON RD.StockItemCode = SD.StockItemHeaderID
    --    AND SD.PropertyID = BT.PropertyId
    --    AND SD.LocationID = LR.StockLocationID

    --INNER JOIN StockItemHeaders AS SH
    --    ON SD.StockItemHeaderID = SH.Id

    --INNER JOIN Categories AS C
    --    ON SH.CategoryID = C.Id

    --INNER JOIN SubCategories AS SC1
    --    ON SH.SubCategoryID = SC1.Id

    --INNER JOIN SubCategories02 AS SC2
    --    ON SH.SubCategory2ID = SC2.Id

    --INNER JOIN Departments AS DD
    --    ON DD.Id = LR.DepartmentID

    --INNER JOIN Locations AS L
    --    ON L.Id = LR.StockLocationID

    --LEFT JOIN eFinancials_Accounting..Destinity_GLIntegrationAccountMapping AS GLM
    --    ON GLM.Level1 = DD.Code
    --    AND GLM.Level2 = C.Code
    --    AND GLM.Level3 = SC1.Code
    --    AND GLM.Level4 = SC2.Code
    --    AND GLM.BlockCode = @BlockCode
    --    AND GLM.GLCompCode = @GLCompCode

    --WHERE
    --    BT.PropertyId = @PropertyId
    --    AND CONVERT(DATE, BT.OrderDate) = CONVERT(DATE, @HotelDate)
    --    AND LR.Code = @Outlet

    --GROUP BY
    --    L.Id,
    --    L.Code,
    --    L.Name,

    --    DD.Id,
    --    DD.Code,
    --    DD.Name,

    --    C.Id,
    --    C.Code,
    --    C.Name,

    --    SC1.Id,
    --    SC1.Code,
    --    SC1.Name,

    --    SC2.Id,
    --    SC2.Code,
    --    SC2.Description,

    --    GLM.AccCode;


    --/* ============================================================
    --   GRN BLOCK CODE
       
    --   Account Mapping:
       
    --   Level1 = Location
    --   Level2 = Category
    --   ============================================================ */

    --INSERT INTO #AccountMappingIssues
    --(
    --    AccMapStatus,
    --    Location,
    --    DepartMentName,
    --    CategoryName,
    --    SubCategory1,
    --    SubCategory2,
    --    BlockCode,
    --    AccCode
    --)
    --SELECT
    --    NULL AS AccMapStatus,

    --    L.Name AS Location,

    --    '' AS DepartMentName,

    --    C.Name AS CategoryName,

    --    '' AS SubCategory1,

    --    '' AS SubCategory2,

    --    @BlockCode2 AS BlockCode,

    --    GLM.AccCode

    --FROM RecipeDetails AS RD

    --INNER JOIN RecipeHeader AS RH
    --    ON RD.RecipeCode = RH.RecipeCode
    --    AND RD.PropertyId = RH.PropertyId

    --INNER JOIN ItemBreakDown AS IB
    --    ON RH.RecipeCode = IB.RecipeCode
    --    AND IB.PropertyId = RH.PropertyId

    --INNER JOIN BillTrans AS BT
    --    ON IB.MainMenuCode = BT.MainMenuCode
    --    AND BT.PropertyId = IB.PropertyId

    --INNER JOIN Location_Ref AS LR
    --    ON BT.Outlet = LR.Code
    --    AND LR.PropertyId = BT.PropertyId

    --INNER JOIN StockItemDetails AS SD
    --    ON RD.StockItemCode = SD.StockItemHeaderID
    --    AND SD.PropertyID = BT.PropertyId
    --    AND SD.LocationID = LR.StockLocationID

    --INNER JOIN StockItemHeaders AS SH
    --    ON SD.StockItemHeaderID = SH.Id

    --INNER JOIN Categories AS C
    --    ON SH.CategoryID = C.Id

    --INNER JOIN SubCategories AS SC1
    --    ON SH.SubCategoryID = SC1.Id

    --INNER JOIN SubCategories02 AS SC2
    --    ON SH.SubCategory2ID = SC2.Id

    --INNER JOIN Departments AS DD
    --    ON DD.Id = LR.DepartmentID

    --INNER JOIN Locations AS L
    --    ON L.Id = LR.StockLocationID

    --LEFT JOIN eFinancials_Accounting..Destinity_GLIntegrationAccountMapping AS GLM
    --    ON GLM.Level1 = L.Code
    --    AND GLM.Level2 = C.Code
    --    AND GLM.BlockCode = @BlockCode2
    --    AND GLM.GLCompCode = @GLCompCode

    --WHERE
    --    BT.PropertyId = @PropertyId
    --    AND CONVERT(DATE, BT.OrderDate) = CONVERT(DATE, @HotelDate)
    --    AND LR.Code = @Outlet

    --GROUP BY
    --    L.Id,
    --    L.Code,
    --    L.Name,

    --    C.Id,
    --    C.Code,
    --    C.Name,

    --    GLM.AccCode;


    --/* ============================================================
    --   UPDATE ACCOUNT MAPPING STATUS
       
    --   This is done ONLY AFTER both KTI and GRN records
    --   have been inserted into the temp table.
    --   ============================================================ */

    --UPDATE #AccountMappingIssues
    --SET AccMapStatus =
    --    CASE
    --        WHEN AccCode IS NULL
    --            THEN 'Not Account Map'
    --        ELSE 'Account Map'
    --    END;


    --/* ============================================================
    --   FINAL SELECT
       
    --   Return ONLY records which are NOT ACCOUNT MAPPED.
       
    --   ONE FINAL SELECT ONLY.
    --   ============================================================ */

    --SELECT
    --    AccMapStatus,
    --    Location,
    --    DepartMentName,
    --    CategoryName,
    --    SubCategory1,
    --    SubCategory2,
    --    BlockCode
    --FROM #AccountMappingIssues
    --WHERE AccMapStatus = 'Not Account Map'
    --ORDER BY
    --    BlockCode,
    --    Location,
    --    DepartMentName,
    --    CategoryName,
    --    SubCategory1,
    --    SubCategory2;


    --/* ============================================================
    --   CLEANUP
    --   ============================================================ */

    --DROP TABLE #AccountMappingIssues;

    PRINT 1

END

GO

