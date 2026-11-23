
-- ==============================================================
-- Author:      Tharuka Sachintha
-- Create date: 2026-09-18
-- Description: Report SP for CompanyWiseItemQtyByUnit.rdl

-- EXEC dbo.SP_RPT_GetCompanyWiseItemQtyByUnit_Thema '2026/09/21', -999, -999, -999, -999
-- ==============================================================
CREATE   PROCEDURE [dbo].[SP_RPT_GetCompanyWiseItemQtyByUnit_Thema]
    @Date        DATETIME,
    @StockItemID INT = -999,
    @CategoryId  INT = -999,
    @SubCatId    INT = -999,
    @SubCat2Id   INT = -999
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AsOf DATE = CAST(@Date AS DATE);

    IF @StockItemID <= 0 SET @StockItemID = NULL;
    IF @CategoryId  <= 0 SET @CategoryId  = NULL;
    IF @SubCatId    <= 0 SET @SubCatId    = NULL;
    IF @SubCat2Id   <= 0 SET @SubCat2Id   = NULL;

    IF @StockItemID IS NOT NULL
    BEGIN
        SET @CategoryId = NULL;
        SET @SubCatId   = NULL;
        SET @SubCat2Id  = NULL;
    END

    DECLARE @ItemCode NVARCHAR(200) = (SELECT StockItemCode FROM dbo.StockItemHeaders WHERE Id = @StockItemID);
    DECLARE @CatName  NVARCHAR(500) = (SELECT LTRIM(RTRIM(Name))        FROM dbo.Categories      WHERE Id = @CategoryId);
    DECLARE @Sub1Name NVARCHAR(500) = (SELECT LTRIM(RTRIM(Name))        FROM dbo.SubCategories   WHERE Id = @SubCatId);
    DECLARE @Sub2Name NVARCHAR(500) = (SELECT LTRIM(RTRIM(Description)) FROM dbo.SubCategories02 WHERE Id = @SubCat2Id);

    ;WITH Conv AS
    (
      
        SELECT LTRIM(RTRIM(F.Name)) AS FromName, LTRIM(RTRIM(T.Name)) AS ToName,
               CAST(U.Value AS FLOAT) AS Rate, U.CompanyId
        FROM dbo.UnitConversions U
        INNER JOIN dbo.Units F ON F.Id = U.FromUnitID
        INNER JOIN dbo.Units T ON T.Id = U.ToUnitID
        WHERE U.Value IS NOT NULL AND U.Value <> 0
        UNION ALL
        SELECT LTRIM(RTRIM(T.Name)), LTRIM(RTRIM(F.Name)),
               1.0 / CAST(U.Value AS FLOAT), U.CompanyId
        FROM dbo.UnitConversions U
        INNER JOIN dbo.Units F ON F.Id = U.FromUnitID
        INNER JOIN dbo.Units T ON T.Id = U.ToUnitID
        WHERE U.Value IS NOT NULL AND U.Value <> 0
    ),
    Items AS
    (
     
        SELECT
            SH.Id            AS ItemID,
            SH.StockItemCode,
            SH.Name          AS ItemName,
            SH.ReportUnitID,
            SH.CompanyId,
            CA.Name          AS CategoryName,
            SU.Name          AS SubCatName,
            SU2.Description  AS SubCat2Name,
            SD.LocationID,
            SD.MasterUnitID,
            CO.Name          AS CompanyName
        FROM dbo.StockItemHeaders SH
        INNER JOIN dbo.StockItemDetails SD ON SD.StockItemHeaderID = SH.Id
        INNER JOIN dbo.Companies CO        ON CO.CompanyID = SH.CompanyId
        INNER JOIN dbo.Categories CA       ON CA.Id = SH.CategoryID
        INNER JOIN dbo.SubCategories SU    ON SU.Id = SH.SubCategoryID
        LEFT JOIN  dbo.SubCategories02 SU2 ON SU2.Id = SH.SubCategory2ID
        INNER JOIN dbo.LOCATIONS LO        ON LO.ID = SD.LocationID AND LO.CompanyID = SH.CompanyId
        WHERE SD.IsActive = 1
          AND SH.ReportUnitID IS NOT NULL                      
          AND (@StockItemID IS NULL OR SH.StockItemCode              = @ItemCode)
          AND (@CategoryId  IS NULL OR LTRIM(RTRIM(CA.Name))         = @CatName)
          AND (@SubCatId    IS NULL OR LTRIM(RTRIM(SU.Name))         = @Sub1Name)
          AND (@SubCat2Id   IS NULL OR LTRIM(RTRIM(SU2.Description)) = @Sub2Name)
    ),
    Converted AS
    (
        SELECT
            I.CompanyName,
            I.StockItemCode,
            I.ItemName,
            I.CategoryName,
            I.SubCatName,
            I.SubCat2Name,
            RU.Name AS ReportUnitName,       
            CASE WHEN UC.Rate IS NOT NULL THEN ISNULL(BAL.Balance, 0) * UC.Rate ELSE 0 END AS DisplayQty,
            CASE WHEN UC.Rate IS NULL AND ISNULL(BAL.Balance, 0) <> 0 THEN 1 ELSE 0 END    AS LocationNotConverted
        FROM Items I
        OUTER APPLY dbo.TVF_RPT_ItemBalanceAsOfDate(@AsOf, I.ItemID, I.LocationID) AS BAL
        LEFT JOIN dbo.Units MU ON MU.Id = I.MasterUnitID
        LEFT JOIN dbo.Units RU ON RU.Id = I.ReportUnitID
       
        OUTER APPLY
        (
            SELECT TOP (1) R.Rate
            FROM
            (
                SELECT CAST(1 AS FLOAT) AS Rate, 0 AS Pref
                WHERE I.MasterUnitID = I.ReportUnitID

                UNION ALL
                SELECT C1.Rate, CASE WHEN C1.CompanyId = I.CompanyId THEN 1 ELSE 2 END
                FROM Conv C1
                WHERE C1.FromName = LTRIM(RTRIM(MU.Name))
                  AND C1.ToName   = LTRIM(RTRIM(RU.Name))

                UNION ALL
                SELECT CA1.Rate * CA2.Rate,
                       CASE WHEN CA1.CompanyId = I.CompanyId AND CA2.CompanyId = I.CompanyId THEN 3 ELSE 4 END
                FROM Conv CA1
                INNER JOIN Conv CA2 ON CA2.FromName = CA1.ToName
                WHERE CA1.FromName = LTRIM(RTRIM(MU.Name))
                  AND CA2.ToName   = LTRIM(RTRIM(RU.Name))
                  AND CA1.ToName  <> LTRIM(RTRIM(MU.Name))
                  AND CA1.ToName  <> LTRIM(RTRIM(RU.Name))
            ) R
            ORDER BY R.Pref, R.Rate
        ) UC
    )
    SELECT
        CompanyName,
        StockItemCode,
        ItemName,
        CategoryName,
        SubCatName,
        SubCat2Name,
        ReportUnitName                          AS DisplayUnitName,
        MAX(LocationNotConverted)               AS NoConversionFlag,
        SUM(LocationNotConverted)               AS UnconvertedLocations,
        CAST(SUM(DisplayQty) AS DECIMAL(18, 4)) AS Qty
    FROM Converted
    GROUP BY CompanyName, StockItemCode, ItemName, CategoryName, SubCatName, SubCat2Name, ReportUnitName
    ORDER BY CategoryName, SubCatName, SubCat2Name, StockItemCode, ItemName, CompanyName;
END

GO

