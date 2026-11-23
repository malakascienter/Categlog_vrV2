--exec [SP_RPT_StockAgeAnalysis_TEST2] -999,'2024-06-25',1,-999,130,5751,20
CREATE PROCEDURE [dbo].[SP_RPT_StockAgeAnalysis_TEST2]
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
    DECLARE @STockItem INT, @TxnId INT, @Location INT, @QTyInHand DECIMAL(18,6), @Quantity DECIMAL(18,6), @StockAgeQty DECIMAL(18,6)

    -- Temporary table to store user locations
    DECLARE @UserLocation TABLE (LocationID INT)
    INSERT INTO @UserLocation (LocationID)
    SELECT LocationID FROM UserWise_Location WHERE UserID = @UserID

    -- Temporary table to store stock balance
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
    WHERE D.LocationID = CASE @LocationID WHEN -999 THEN D.LocationID ELSE @LocationID END
      AND H.CategoryID = CASE @CategoryID WHEN -999 THEN H.CategoryId ELSE @CategoryID END
      AND H.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN H.SubCategoryID ELSE @SubcategoryID END
      AND H.Id = CASE @StockItemID WHEN -999 THEN H.Id ELSE @StockItemID END
      AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END
      AND D.IsActive = 1
      AND dbo.FN_GetStockInHand(H.CompanyId, D.LocationID, H.Id) > 0
      AND dbo.GetBalance(@Date, H.Id, D.LocationID, 0, 1) > 0

    -- Temporary table to store age breakdown
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

    -- Temporary table to store final data
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

    -- Loop through stock balance
    WHILE (SELECT COUNT(*) FROM @TempStockBalance WHERE QuantityInHand > StockAgeQty) > 0
    BEGIN
        SELECT TOP(1) @STockItem = StockItemId, @Location = LocationID, @QTyInHand = QuantityInHand, @StockAgeQty = StockAgeQty 
        FROM @TempStockBalance
        WHERE QuantityInHand > StockAgeQty

        -- Temporary table to store transaction data
        DECLARE @TempTxnData TABLE
        (
            TransactionDate DATETIME,
            Quantity DECIMAL(18,6),
            Id INT,
            StockItemID INT,
            TransactionType VARCHAR(10),
            StockAgeQty DECIMAL(18,6)
        )

        -- Insert transaction data
        INSERT INTO @TempTxnData
        SELECT DISTINCT 
            TH.TransactionDate, 
            TD.Quantity,
            TD.Id,
            TD.StockItemID,
            TH.TransactionType,
            0 AS StockAgeQty
        FROM StockTransactionHeaders AS TH WITH (NOLOCK)
        INNER JOIN StockTransactionDetails AS TD WITH (NOLOCK) ON TH.Id = TD.StockTransactionHeaderID
        WHERE TH.TransactionType IN ('GR', 'TI', 'AA') 
          AND TD.StockItemID = @STockItem 
          AND TH.LocationID = @Location 
          AND TH.PropertyID = CASE WHEN @PropertyID = -999 THEN TH.PropertyID ELSE @PropertyID END
          AND TD.TxnType = 'P'
        ORDER BY TH.TransactionDate DESC

        -- Loop through transaction data
        WHILE @StockAgeQty < @QTyInHand AND (SELECT COUNT(*) FROM @TempTxnData) > 0
        BEGIN
            SELECT TOP(1) @Quantity = Quantity, @TxnId = Id FROM @TempTxnData ORDER BY TransactionDate DESC

            SET @StockAgeQty = @Quantity + @StockAgeQty

            UPDATE @TempStockBalance
            SET StockAgeQty = @StockAgeQty
            WHERE StockItemId = @STockItem AND LocationID = @Location

            INSERT INTO @TempData
            (
                StockItemId, Quantity, NoOfDays, QtyInHand, LocationId, TXNTyp, TransactionDate, ItemName, ItemCode, Unit, CatName, SubCatName, Location, AgeCategory, AgeCategorySeq
            )
            SELECT TOP(1)
                txn.StockItemID,
                Quantity,
                DATEDIFF(DAY, txn.TransactionDate, GETDATE()) AS NoOfDays,
                @QTyInHand,
                L.Id,
                CASE 
                    WHEN TransactionType = 'GR' THEN 'Good Receive Note' 
                    WHEN TransactionType = 'TI' THEN 'Transfer In' 
                    WHEN TransactionType = 'AA' THEN 'Reconciliation' 
                END AS TXNTyp,
                txn.TransactionDate,
                H.Name AS ItemName,
                H.StockItemCode AS ItemCode,
                U.Name AS Unit,
                C.Name AS CatName,
                S.Name AS SubCatName,
                L.Name AS Location,
                AB.TypeName AS AgeCategory,
                AB.Id AS AgeCategorySeq
            FROM @TempTxnData txn
            INNER JOIN dbo.StockItemDetails AS D WITH (NOLOCK) ON txn.StockItemID = D.StockItemHeaderID
            INNER JOIN dbo.StockItemHeaders AS H WITH (NOLOCK) ON H.Id = D.StockItemHeaderID
            INNER JOIN dbo.Categories AS C WITH (NOLOCK) ON C.Id = H.CategoryID
            INNER JOIN dbo.SubCategories AS S WITH (NOLOCK) ON S.Id = H.SubCategoryID
            INNER JOIN dbo.Locations AS L WITH (NOLOCK) ON L.Id = D.LocationID
            INNER JOIN @UserLocation AS UL ON UL.LocationID = L.Id
            INNER JOIN dbo.Units AS U WITH (NOLOCK) ON U.Id = D.MasterUnitID
            INNER JOIN @AgeBreakDown AS AB ON AB.FromVal <= DATEDIFF(DAY, txn.TransactionDate, GETDATE()) AND AB.ToVal >= DATEDIFF(DAY, txn.TransactionDate, GETDATE())
            ORDER BY txn.TransactionDate DESC

            DELETE FROM @TempTxnData WHERE Id = @TxnId
        END
    END

    SELECT DISTINCT * FROM @TempData
END

GO

