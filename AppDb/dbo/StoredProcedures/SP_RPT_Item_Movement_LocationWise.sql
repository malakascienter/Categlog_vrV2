
CREATE PROCEDURE [dbo].[SP_RPT_Item_Movement_LocationWise]
(
    @DateFrom           DATE = '2018-08-10',
    @DateTo             DATE = '2018-09-30',
    @StockItemID        INT  = -999,
    @byValue            BIT  = 0,
    @CategoryId         INT  = -999,
    @SubCatId           INT  = -999,
    @MultipleLocationID VARCHAR(MAX)
)
AS
BEGIN
    SET NOCOUNT ON;

    /* -- 0. Selected locations (explicit IDs only) --------------------------- */
    CREATE TABLE #Loc
    (
        LocationID   INT NOT NULL PRIMARY KEY,
        LocationName NVARCHAR(500)
    );

    INSERT INTO #Loc (LocationID, LocationName)
    SELECT L.Id, CAST(L.Name AS NVARCHAR(500))
    FROM dbo.Locations AS L WITH (NOLOCK)
    WHERE L.Id IN (SELECT TRY_CAST(LTRIM(RTRIM(S.value)) AS INT)
                   FROM STRING_SPLIT(ISNULL(@MultipleLocationID, ''), ',') AS S);

    /* -- 1. Candidate items ------------------------------------------------ */
    CREATE TABLE #Items
    (
        StockItemID   INT NOT NULL PRIMARY KEY,
        StockItemCode NVARCHAR(200),
        Name          NVARCHAR(500),
        CategoryName  NVARCHAR(500)
    );

    INSERT INTO #Items (StockItemID, StockItemCode, Name, CategoryName)
    SELECT IH.Id, CAST(IH.StockItemCode AS NVARCHAR(200)), CAST(IH.Name AS NVARCHAR(500)),
           CAST(C.Name AS NVARCHAR(500)) AS CategoryName
    FROM dbo.StockItemHeaders AS IH WITH (NOLOCK)
    LEFT JOIN dbo.Categories AS C ON C.Id = IH.CategoryID
    WHERE (@StockItemID = -999 OR IH.Id             = @StockItemID)
      AND (@CategoryId  = -999 OR IH.CategoryID     = @CategoryId)
      AND (@SubCatId    = -999 OR IH.SubCategoryID  = @SubCatId)
    OPTION (RECOMPILE);

    /* -- 2. Balances per (item, location): one set-based pass --------------- */
    CREATE TABLE #Bal
    (
        StockItemID INT NOT NULL,
        LocationID  INT NOT NULL,
        OpenQty  DECIMAL(18,6) NOT NULL,
        OpenVal  DECIMAL(18,6) NOT NULL,
        CloseQty DECIMAL(18,6) NOT NULL,
        CloseVal DECIMAL(18,6) NOT NULL,
        PRIMARY KEY (StockItemID, LocationID)
    );

    ;WITH Txn AS
    (
        SELECT D.StockItemID, H.LocationID, D.NewQuantity, D.NewAveragePrice,
               H.TransactionDate, H.CreatedDate,
               IsOpen = CASE WHEN H.TransactionDate < @DateFrom THEN 1 ELSE 0 END
        FROM #Loc AS L
        JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
             ON H.LocationID = L.LocationID
        JOIN dbo.StockTransactionDetails AS D WITH (NOLOCK)
             ON D.StockTransactionHeaderID = H.Id
        WHERE H.TransactionDate < DATEADD(DAY, 1, @DateTo)
          AND EXISTS (SELECT 1 FROM #Items I
                      WHERE I.StockItemID = D.StockItemID)
          AND EXISTS (SELECT 1 FROM dbo.StockItemDetails SD WITH (NOLOCK)
                      WHERE SD.StockItemHeaderID = D.StockItemID
                        AND SD.LocationID        = H.LocationID)
    ),
    R AS
    (
        SELECT *,
               rnClose = ROW_NUMBER() OVER (PARTITION BY StockItemID, LocationID
                                            ORDER BY TransactionDate DESC, CreatedDate DESC),
               rnOpen  = ROW_NUMBER() OVER (PARTITION BY StockItemID, LocationID, IsOpen
                                            ORDER BY TransactionDate DESC, CreatedDate DESC)
        FROM Txn
    )
    INSERT INTO #Bal (StockItemID, LocationID, OpenQty, OpenVal, CloseQty, CloseVal)
    SELECT StockItemID, LocationID,
           ISNULL(MAX(CASE WHEN IsOpen = 1 AND rnOpen = 1 THEN NewQuantity END), 0),
           ISNULL(MAX(CASE WHEN IsOpen = 1 AND rnOpen = 1 THEN NewQuantity * NewAveragePrice END), 0),
           ISNULL(MAX(CASE WHEN rnClose = 1 THEN NewQuantity END), 0),
           ISNULL(MAX(CASE WHEN rnClose = 1 THEN NewQuantity * NewAveragePrice END), 0)
    FROM R
    WHERE rnClose = 1 OR (IsOpen = 1 AND rnOpen = 1)
    GROUP BY StockItemID, LocationID
    OPTION (RECOMPILE);

    /* -- 3. Movements, aggregated from the transaction side first ----------- */
    CREATE TABLE #Mv
    (
        StockItemID     INT NOT NULL,
        LocationID      INT NOT NULL,
        TransactionType NVARCHAR(400) NULL,
        UnitPrice       DECIMAL(18,6) NOT NULL,
        Qty             DECIMAL(38,6) NULL,
        Val             DECIMAL(38,6) NULL
    );

    INSERT INTO #Mv (StockItemID, LocationID, TransactionType, UnitPrice, Qty, Val)
    SELECT D.StockItemID, H.LocationID, H.TransactionType, D.UnitPrice,
           SUM(CASE WHEN D.TxnType = 'M' AND H.TransactionType = 'AA'
                    THEN -1 * (D.Quantity * D.MasterUnitConversion)
                    ELSE      (D.Quantity * D.MasterUnitConversion) END),
           SUM(D.Quantity * D.UnitPrice)
    FROM #Loc AS L
    JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
         ON H.LocationID = L.LocationID
    JOIN dbo.StockTransactionDetails AS D WITH (NOLOCK)
         ON D.StockTransactionHeaderID = H.Id
    WHERE H.TransactionDate BETWEEN @DateFrom AND @DateTo
      AND EXISTS (SELECT 1 FROM #Items I
                  WHERE I.StockItemID = D.StockItemID)
    GROUP BY D.StockItemID, H.LocationID, H.TransactionType, D.UnitPrice
    OPTION (RECOMPILE);

    CREATE CLUSTERED INDEX IX_Mv ON #Mv (StockItemID, LocationID);

    /* -- 4. Movement rows, then descriptive columns --------------------------- */
    -- Same rows as the original step 4. Its GROUP BY also listed item code/name,
    -- category, unit, location name and the balances, but all of those depend
    -- only on (StockItemID, LocationID), so grouping on the IDs gives the same
    -- groups without hashing or sorting text.
    CREATE TABLE #TT
    (
        Code   NVARCHAR(400) NULL,
        Name   NVARCHAR(400) NULL,
        SortID INT NULL
    );

    INSERT INTO #TT (Code, Name, SortID)
    SELECT CAST(TR.Code AS NVARCHAR(400)), CAST(TR.Name AS NVARCHAR(400)), TR.SortID
    FROM dbo.TransactionTypes AS TR WITH (NOLOCK);

    CREATE TABLE #MvT
    (
        LocationID      INT NOT NULL,
        StockItemID     INT NOT NULL,
        TransactionType NVARCHAR(400) NULL,
        SortID          INT NULL,
        UnitPrice       DECIMAL(18,6) NOT NULL,
        Qty             DECIMAL(38,6) NULL,
        Val             DECIMAL(38,6) NULL
    );

    INSERT INTO #MvT (LocationID, StockItemID, TransactionType, SortID, UnitPrice, Qty, Val)
    SELECT Mv.LocationID, Mv.StockItemID, TR.Name, TR.SortID, Mv.UnitPrice,
           SUM(Mv.Qty), SUM(Mv.Val)
    FROM #Mv AS Mv
    JOIN #TT AS TR
         ON TR.Code = Mv.TransactionType
    GROUP BY Mv.LocationID, Mv.StockItemID, TR.Name, TR.SortID, Mv.UnitPrice
    OPTION (RECOMPILE);

    SELECT M.LocationID, L.LocationName AS Location,
           IH.StockItemID, IH.StockItemCode, IH.Name, IH.CategoryName,
           CAST(U.Name AS NVARCHAR(200)) AS UnitName,
           ISNULL(B.OpenQty , 0) AS OpeingBalance,
           ISNULL(B.CloseQty, 0) AS ClosingBalance,
           ISNULL(B.OpenVal , 0) AS OpeingBalanceVal,
           ISNULL(B.CloseVal, 0) AS ClosingBalanceVal,
           M.TransactionType,
           M.Qty,
           M.UnitPrice,
           M.Val AS Value,
           M.SortID
    INTO #TempTable
    FROM #MvT AS M
    JOIN #Loc AS L
         ON L.LocationID = M.LocationID
    JOIN #Items AS IH
         ON IH.StockItemID = M.StockItemID
    JOIN dbo.StockItemDetails AS ID WITH (NOLOCK)
         ON ID.StockItemHeaderID = M.StockItemID
        AND ID.LocationID        = M.LocationID
    JOIN dbo.Units AS U WITH (NOLOCK)
         ON ID.MasterUnitID = U.Id
    LEFT JOIN #Bal AS B
         ON B.StockItemID = M.StockItemID
        AND B.LocationID  = M.LocationID
    OPTION (RECOMPILE);

    CREATE CLUSTERED INDEX IX_TempTable ON #TempTable (StockItemID, LocationID);

    /* -- 5. Final result ---------------------------------------------------- */
    SELECT LocationID, Location,
           StockItemID, StockItemCode, Name, CategoryName, UnitName,
           OpeingBalance, ClosingBalance, OpeingBalanceVal, ClosingBalanceVal,
           TransactionType, Qty, UnitPrice, Value, SortID
    FROM
    (
        SELECT LocationID, Location,
               StockItemID, StockItemCode, Name, CategoryName, UnitName,
               OpeingBalance, ClosingBalance, OpeingBalanceVal, ClosingBalanceVal,
               TransactionType, Qty, UnitPrice, Value, SortID
        FROM #TempTable

        UNION ALL

        -- items with no movement in the period, per selected location
        -- 2026-09-30: return the real opening/closing quantity. The original SP
        -- returns 0, 0 here while showing the real values, so an item with stock
        -- but no movement showed "0.00" next to its opening/closing value.
        -- 2026-09-30: only items with an opening/closing quantity or value.
        -- Items with no movement, no stock and no value were 72% of the rows for
        -- all locations (69,837 of 96,849 for 28-29 Sep) and pushed the report
        -- past the viewer's request timeout. An item-location pair with no
        -- transaction up to @DateTo has no #Bal row, so the INNER JOIN drops it.
        SELECT L.LocationID, L.LocationName,
               SH.StockItemID, SH.StockItemCode, SH.Name, SH.CategoryName, CAST(U.Name AS NVARCHAR(200)),
               B.OpenQty, B.CloseQty,
               B.OpenVal, B.CloseVal,
               'NULL', 0, 0, 0, 1
        FROM #Items AS SH
        JOIN dbo.StockItemDetails AS SD WITH (NOLOCK)
             ON SD.StockItemHeaderID = SH.StockItemID
        JOIN #Loc AS L
             ON L.LocationID = SD.LocationID
        JOIN dbo.Units AS U WITH (NOLOCK)
             ON U.Id = SD.MasterUnitID
        JOIN #Bal AS B
             ON B.StockItemID = SH.StockItemID
            AND B.LocationID  = SD.LocationID
        WHERE NOT EXISTS (SELECT 1 FROM #TempTable T
                          WHERE T.StockItemID = SH.StockItemID
                            AND T.LocationID  = SD.LocationID)
          AND (B.OpenQty <> 0 OR B.CloseQty <> 0 OR B.OpenVal <> 0 OR B.CloseVal <> 0)
    ) AS A
    ORDER BY Location, ClosingBalance DESC, ClosingBalanceVal DESC, StockItemCode
    OPTION (RECOMPILE);

    DROP TABLE #Loc, #Items, #Bal, #Mv, #TT, #MvT, #TempTable;
END

GO

