--exec [SP_RPT_StockAgeAnalysis_TEST3] -999,'2024-06-25',1,-999,130,5751,20
CREATE PROCEDURE [dbo].[SP_RPT_StockAgeAnalysis_TEST3]
(
    @StockItemID INT = -999,
    @Date DATE = '2021-03-03',
    @CategoryID INT = -999,
    @SubcategoryID INT = -999,
    @LocationID INT = 4,
    @UserID INT = 1,
    @PropertyID INT = -999
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @StockItem INT, @TxnId INT, @Location INT, @QTyInHand DECIMAL(18,6), @Quantity DECIMAL(18,6), @StockAgeQty DECIMAL(18,6)

    -- Table variable to store user locations
    DECLARE @UserLocation TABLE (LocationID INT)
    INSERT INTO @UserLocation (LocationID)
    SELECT LocationID FROM UserWise_Location WHERE UserID = @UserID

    -- Table variable to store stock balance
    DECLARE @TempStockBalance TABLE
    (
        StockItemId INT,
        QuantityInHand DECIMAL(18,6),
        LocationID INT,
        StockItemCode VARCHAR(100),
        Quantity DECIMAL(18,6),
        Value DECIMAL(18,6),
        StockAgeQty DECIMAL(18,6)
    )

    -- Insert stock balance data
    INSERT INTO @TempStockBalance
    SELECT DISTINCT 
        D.StockItemId,
        dbo.FN_GetStockInHand(H.CompanyId, D.LocationID, H.Id) AS QuantityInHand,
        D.LocationID,
        H.StockItemCode,
        dbo.GetBalance(@Date, H.Id, D.LocationID, 0, 0) AS Quantity,
        dbo.GetBalance(@Date, H.Id, D.LocationID, 0, 1) AS Value,
        0 AS StockAgeQty
    FROM dbo.StockItemDetails AS D WITH (NOLOCK)
    INNER JOIN dbo.StockItemHeaders AS H WITH (NOLOCK) ON H.Id = D.StockItemHeaderID
    INNER JOIN dbo.Locations AS L WITH (NOLOCK) ON L.Id = D.LocationID
    INNER JOIN StockTransactionDetails AS TD WITH (NOLOCK) ON TD.StockItemID = H.Id AND TD.TxnType = 'P'
    INNER JOIN StockTransactionHeaders AS TH WITH (NOLOCK) ON TH.Id = TD.StockTransactionHeaderID AND TH.TransactionType IN ('GR', 'TI', 'AA')
    WHERE 
        D.LocationID = ISNULL(NULLIF(@LocationID, -999), D.LocationID)
        AND H.CategoryID = ISNULL(NULLIF(@CategoryID, -999), H.CategoryID)
        AND H.SubCategoryID = ISNULL(NULLIF(@SubcategoryID, -999), H.SubCategoryID)
        AND H.Id = ISNULL(NULLIF(@StockItemID, -999), H.Id)
        AND D.PropertyID = ISNULL(NULLIF(@PropertyID, -999), D.PropertyID)
        AND D.IsActive = 1
        AND dbo.FN_GetStockInHand(H.CompanyId, D.LocationID, H.Id) > 0
        AND dbo.GetBalance(@Date, H.Id, D.LocationID, 0, 1) > 0

    -- Table variable to store age breakdown
    DECLARE @AgeBreakDown TABLE
    (
        Id INT,
        TypeName VARCHAR(500),
        FromVal INT,
        ToVal INT
    )

    -- Insert age breakdown data
    INSERT INTO @AgeBreakDown (Id, TypeName, FromVal, ToVal)
    VALUES
        (1, '0 to 30 Days', 0, 30),
        (2, '31 to 60 Days', 31, 60),
        (3, '61 to 90 Days', 61, 90),
        (4, '91 to 120 Days', 91, 120),
        (5, '121 to 180 Days', 121, 180),
        (6, '181 to 365 Days', 181, 365),
        (7, 'More than 365 Days', 366, 50000)

    -- Table variable to store final data
    DECLARE @TempData TABLE
    (
        StockItemId INT,
        ItemName VARCHAR(500),
        ItemCode VARCHAR(300),
        Unit VARCHAR(300),
        Quantity DECIMAL(18,6),
        NoOfDays INT,
        QtyInHand DECIMAL(18,6),
        LocationId INT,
        TXNTyp VARCHAR(200),
        TransactionDate VARCHAR(25),
        CatName VARCHAR(300),
        SubCatName VARCHAR(300),
        Location VARCHAR(300),
        AgeCategory VARCHAR(300),
        AgeCategorySeq INT
    )

    -- Insert all transaction data in one go
    DECLARE @AllTxnData TABLE
    (
        StockItemID INT,
        TransactionDate DATETIME,
        Quantity DECIMAL(18,6),
        TransactionType VARCHAR(10),
        LocationID INT
    )

    INSERT INTO @AllTxnData
    SELECT 
        TD.StockItemID,
        TH.TransactionDate, 
        TD.Quantity,
        TH.TransactionType,
        TH.LocationID
    FROM StockTransactionHeaders AS TH WITH (NOLOCK)
    INNER JOIN StockTransactionDetails AS TD WITH (NOLOCK) ON TH.Id = TD.StockTransactionHeaderID
    WHERE TH.TransactionType IN ('GR', 'TI', 'AA') 
      AND TD.TxnType = 'P'
      AND TH.PropertyID = ISNULL(NULLIF(@PropertyID, -999), TH.PropertyID)
    ORDER BY TH.TransactionDate DESC

    -- Merge loops to handle stock balance and transactions
    WHILE EXISTS (SELECT 1 FROM @TempStockBalance WHERE QuantityInHand > StockAgeQty)
    BEGIN
        SELECT TOP(1) @StockItem = StockItemId, @Location = LocationID, @QTyInHand = QuantityInHand, @StockAgeQty = StockAgeQty 
        FROM @TempStockBalance
        WHERE QuantityInHand > StockAgeQty

        -- Update the stock balance and insert into @TempData
        UPDATE tsb
        SET StockAgeQty = tsb.StockAgeQty + atd.Quantity
        OUTPUT
            inserted.StockItemId,
            atd.Quantity,
            DATEDIFF(DAY, atd.TransactionDate, @Date) AS NoOfDays,
            inserted.QuantityInHand,
            inserted.LocationID,
            CASE 
                WHEN atd.TransactionType = 'GR' THEN 'Good Receive Note' 
                WHEN atd.TransactionType = 'TI' THEN 'Transfer In' 
                WHEN atd.TransactionType = 'AA' THEN 'Reconciliation' 
            END AS TXNTyp,
            CONVERT(VARCHAR(25), atd.TransactionDate, 120) AS TransactionDate,
            H.Name AS ItemName,
            H.StockItemCode AS ItemCode,
            U.Name AS Unit,
            C.Name AS CatName,
            S.Name AS SubCatName,
            L.Name AS Location,
            AB.TypeName AS AgeCategory,
            AB.Id AS AgeCategorySeq
        INTO @TempData
        FROM @TempStockBalance tsb
        INNER JOIN @AllTxnData atd ON tsb.StockItemId = atd.StockItemID AND tsb.LocationID = atd.LocationID
        INNER JOIN dbo.StockItemDetails AS D WITH (NOLOCK) ON atd.StockItemID = D.StockItemHeaderID
        INNER JOIN dbo.StockItemHeaders AS H WITH (NOLOCK) ON H.Id = D.StockItemHeaderID
        INNER JOIN dbo.Categories AS C WITH (NOLOCK) ON C.Id = H.CategoryID
        INNER JOIN dbo.SubCategories AS S WITH (NOLOCK) ON S.Id = H.SubCategoryID
        INNER JOIN dbo.Locations AS L WITH (NOLOCK) ON L.Id = D.LocationID
        INNER JOIN @UserLocation AS UL ON UL.LocationID = L.Id
        INNER JOIN dbo.Units AS U WITH (NOLOCK) ON U.Id = D.MasterUnitID
        INNER JOIN @AgeBreakDown AS AB ON AB.FromVal <= DATEDIFF(DAY, atd.TransactionDate, @Date) AND AB.ToVal >= DATEDIFF(DAY, atd.TransactionDate, @Date)
        WHERE tsb.StockItemId = @StockItem AND tsb.LocationID = @Location AND tsb.StockAgeQty < tsb.QuantityInHand

        DELETE FROM @AllTxnData WHERE StockItemID = @StockItem AND LocationID = @Location
    END

    SELECT DISTINCT * FROM @TempData
END

GO

