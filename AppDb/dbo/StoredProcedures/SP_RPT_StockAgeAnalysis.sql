--====================================================
-- Created by		: Nivesh
-- Created Date		: 2025-11-20
-- Description		: Stock Aging Report
--  [dbo].[SP_RPT_StockAgeAnalysis] 2,'2025-12-31',-999,-999,5,9215,1

--====================================================
CREATE     PROCEDURE [dbo].[SP_RPT_StockAgeAnalysis]
(
    @StockItemID INT = -999,
    @Date DATE = '2023-03-03',
    @CategoryID INT = -999,
    @SubcategoryID INT = -999,
    @LocationID INT = 4,
    @UserID INT = 1,
    @PropertyID INT = -999
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE 
        @STockItem INT, 
        @TxnId INT, 
        @Location INT, 
        @QTyInHand DECIMAL(18,6), 
        @Quantity DECIMAL(18,6), 
        @StockAgeQty DECIMAL(18,6);

    -- User location table
    CREATE TABLE #UserLocation (LocationID INT);

    INSERT INTO #UserLocation (LocationID)
    SELECT LocationID 
    FROM UserWise_Location
    WHERE UserID = @UserID;

    -- Stock age breakdown
    CREATE TABLE #AgeBreakDown(
        Id INT,
        TypeName VARCHAR(500),
        FromVal INT,
        ToVal INT
    );

    INSERT INTO #AgeBreakDown (Id, TypeName, FromVal, ToVal)
    SELECT Id, TypeName, FromVal, ToVal
    FROM StockAgeBreakDown
    WHERE IsActive = 1;

    -- Temporary bucket qty
    CREATE TABLE #TempBucketQty(
        StockItemId INT,
		ItemName VARCHAR(100),
        LocationID INT,
        InQty DECIMAL(18,6),
        BucketQty DECIMAL(18,6),
        Bucket VARCHAR(500),
        BucketID INT,
        OutQty DECIMAL(18,6),
		NewAveragePrice DECIMAL(18,6),
		MasterUnitID INT,
		StockItemCode VARCHAR(100),
		[Location] VARCHAR(100) 
    );

	CREATE TABLE #TempData(
		StockItemID INT,
		ItemName VARCHAR(100),
        LocationID INT,
		StockItemCode VARCHAR(100),
        TxnType CHAR(1),
        TransactionDate DATE,
        TransactionType CHAR(4),
        PropertyID INT,
        Quantity DECIMAL(18,6),
        PhysicalQuantity DECIMAL(18,6),
        NewQuantity DECIMAL(18,6),
        MasterUnitID INT,
		NewAveragePrice DECIMAL(18,6),
		[Location] VARCHAR(100) 
	)

	CREATE TABLE #TempDataOut(
		StockItemID INT, 
		LocationID INT, 
		OutQty DECIMAL(18,6)
	)
    ---------------------------------------------------
    -- 1. Load Stock Transaction Data
    ---------------------------------------------------
	INSERT INTO #TempData (StockItemID,
		LocationID,
        TxnType,
        TransactionDate,
        TransactionType,
        PropertyID,
        Quantity,
        PhysicalQuantity,
        NewQuantity,
        MasterUnitID,
		NewAveragePrice,
		StockItemCode,
		[Location],
		ItemName)
    SELECT 
        TD.StockItemID,
        TH.LocationID,
        TD.TxnType,
        TH.TransactionDate,
        TH.TransactionType,
        TH.PropertyID,
        ([dbo].[FN_GetUnitConvertionRate](@PropertyId, td.TxnUnitID, td.MasterUnitID) * ISNULL(TD.Quantity,0)) AS Quantity,
        ISNULL(TD.PhysicalQuantity,0) PhysicalQuantity,
        ISNULL(TD.NewQuantity,0) NewQuantity,
        TSD.MasterUnitID,
		ISNULL(TD.NewAveragePrice,0) NewAveragePrice,
		SIH.StockItemCode,
		L.Name AS [Location],
		SIH.Name AS ItemName
    FROM StockTransactionDetails TD WITH (NOLOCK)
    INNER JOIN StockTransactionHeaders TH WITH (NOLOCK) 
        ON TH.Id = TD.StockTransactionHeaderID 
    INNER JOIN StockItemHeaders SIH 
        ON SIH.Id = TD.StockItemID
    INNER JOIN StockItemDetails TSD 
        ON TSD.StockItemHeaderID = SIH.Id 
       AND TSD.LocationID = TH.LocationID
	INNER JOIN #UserLocation AS UL ON UL.LocationID = TH.LocationID
	INNER JOIN Locations AS L ON L.Id = TH.LocationID
    WHERE TSD.LocationID = CASE @LocationID WHEN -999 THEN TSD.LocationID ELSE @LocationID END
      AND SIH.CategoryID = CASE @CategoryID WHEN -999 THEN SIH.CategoryId ELSE @CategoryId END 
      AND SIH.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN SIH.SubCategoryID ELSE @SubcategoryID END 
      AND SIH.Id = CASE @StockItemID WHEN -999 THEN SIH.Id ELSE @StockItemID END 
      AND TSD.PropertyID = CASE WHEN @PropertyID = -999 THEN TSD.PropertyID ELSE @PropertyID END 
      --AND TSD.IsActive = 1 
      --AND TSD.QuantityInHand > 0
      AND CAST(CONVERT(VARCHAR, CAST([dbo].[GetBalance](@Date, SIH.Id, TSD.LocationID, 0, 0) AS DECIMAL(18,6)), 1) AS DECIMAL(18,6)) > 0
	  AND TH.TransactionDate <= @Date ;





	
	 
    ---------------------------------------------------
	IF(@LocationID <> -999)
	BEGIN
		-- 2. Calculate OUT QTY (Minus Transactions)
		---------------------------------------------------
		INSERT INTO #TempDataOut(StockItemID, LocationID, OutQty)
		SELECT 
			T.StockItemID, 
			T.LocationID, 
			SUM(ISNULL(Quantity,0)) AS OutQty
		FROM #TempData T
		WHERE T.TxnType = 'M'
		GROUP BY T.StockItemID, T.LocationID;

		
		

		---------------------------------------------------
		-- 3. Fill #TempBucketQty (Initial Bucket Qty)
		---------------------------------------------------
		INSERT INTO #TempBucketQty(
			StockItemId,
			LocationID,
			InQty,
			BucketQty,
			Bucket,
			BucketID,
			OutQty,
			NewAveragePrice,
			MasterUnitID,
			StockItemCode,
			[Location],
			ItemName
		)
		SELECT 
			T.StockItemID,
			T.LocationID,
			SUM(ISNULL(T.Quantity,0)) AS InQty,
			SUM(ISNULL(T.Quantity,0)) AS BucketQty,
			AB.TypeName AS Bucket,
			AB.Id AS BucketID,
			ISNULL(TDO.OutQty,0) OutQty,
			AVG(ISNULL(T.NewAveragePrice,0)) AS NewAveragePrice,
			T.MasterUnitID,
			T.StockItemCode,
			T.[Location],
			T.ItemName
		FROM #TempData T
		INNER JOIN #AgeBreakDown AB 
			ON AB.FromVal <= DATEDIFF(DAY, T.TransactionDate, @Date)
		   AND AB.ToVal >= DATEDIFF(DAY, T.TransactionDate, @Date)
		LEFT JOIN #TempDataOut TDO 
			ON TDO.StockItemID = T.StockItemID 
		   AND TDO.LocationID = T.LocationID
		WHERE T.TxnType = 'P'
		  AND T.TransactionType IN ('GR','AA','TI')
		GROUP BY 
			T.StockItemID, 
			T.LocationID, 
			AB.TypeName,
			AB.Id,
			TDO.OutQty,
			T.MasterUnitID,
			T.StockItemCode,
			[Location],
			T.ItemName;

			


		---------------------------------------------------
		-- 4. FIFO Allocation (Older First  Highest BucketID)
		---------------------------------------------------
		;WITH CTE AS (
			SELECT
				*,
				SUM(BucketQty) OVER (
					PARTITION BY StockItemId, LocationID 
					ORDER BY BucketID DESC   -- FIFO: older first
				) AS CumIn,
				OutQty AS TotalOut
			FROM #TempBucketQty
		),
		Allocated AS (
			SELECT
				*,
				CASE 
					WHEN TotalOut >= CumIn THEN 0
					WHEN TotalOut < (CumIn - BucketQty) THEN BucketQty
					ELSE BucketQty - (TotalOut - (CumIn - BucketQty))
				END AS RemainingQty
			FROM CTE
		)
		UPDATE T
		SET T.BucketQty = A.RemainingQty
		FROM #TempBucketQty T
		JOIN Allocated A
			ON T.StockItemId = A.StockItemId
		   AND T.LocationID = A.LocationID
		   AND T.BucketID = A.BucketID;

		---------------------------------------------------
		-- Final Result.
		---------------------------------------------------


		SELECT TBQ.*, C.Name AS Category, S.Name AS SubCategory, u.Name AS MasterUnit 
		FROM #TempBucketQty TBQ
		INNER JOIN StockItemHeaders H ON H.Id = TBQ.StockItemId
		INNER JOIN dbo.Categories AS C WITH (NOLOCK) ON C.Id = H.CategoryID
		INNER JOIN dbo.SubCategories AS S WITH (NOLOCK) ON S.Id = H.SubCategoryID
		--INNER JOIN dbo.Locations AS L WITH (NOLOCK) ON L.Id = TBQ.LocationID
		--INNER JOIN #UserLocation AS UL ON UL.LocationID = L.Id
		INNER JOIN dbo.Units AS U WITH (NOLOCK) ON U.Id = TBQ.MasterUnitID
		ORDER BY TBQ.StockItemId, TBQ.LocationID, TBQ.BucketID;	

		--SELECT SUM(BucketQty)
		--FROM #TempBucketQty

		--SELECT ItemName,SUM(BucketQty)
		--FROM #TempBucketQty
		--group by ItemName
	END
	ELSE
	BEGIN
		-- 2. Calculate OUT QTY (Minus Transactions)
		---------------------------------------------------
		INSERT INTO #TempDataOut(StockItemID, OutQty)
		SELECT 
			T.StockItemID,
			SUM(ISNULL(Quantity,0)) AS OutQty
		FROM #TempData T
		WHERE T.TxnType = 'M'
		GROUP BY T.StockItemID;

		---------------------------------------------------
		-- 3. Fill #TempBucketQty (Initial Bucket Qty)
		---------------------------------------------------
		INSERT INTO #TempBucketQty(
			StockItemId,
			InQty,
			BucketQty,
			Bucket,
			BucketID,
			OutQty,
			NewAveragePrice,
			MasterUnitID,
			StockItemCode,
			ItemName
		)
		SELECT 
			T.StockItemID,
			SUM(ISNULL(T.Quantity,0)) AS InQty,
			SUM(ISNULL(T.Quantity,0)) AS BucketQty,
			AB.TypeName AS Bucket,
			AB.Id AS BucketID,
			ISNULL(TDO.OutQty,0) OutQty,
			AVG(ISNULL(T.NewAveragePrice,0)) AS NewAveragePrice,
			T.MasterUnitID,
			T.StockItemCode,
			T.ItemName
		FROM #TempData T
		INNER JOIN #AgeBreakDown AB 
			ON AB.FromVal <= DATEDIFF(DAY, T.TransactionDate, @Date)
		   AND AB.ToVal >= DATEDIFF(DAY, T.TransactionDate, @Date)
		LEFT JOIN #TempDataOut TDO 
			ON TDO.StockItemID = T.StockItemID 
		WHERE T.TxnType = 'P'
		  AND T.TransactionType IN ('GR','AA','TI')
		GROUP BY 
			T.StockItemID, 
			AB.TypeName,
			AB.Id,
			TDO.OutQty,
			T.MasterUnitID,
			T.StockItemCode,
			T.ItemName;

		---------------------------------------------------
		-- 4. FIFO Allocation (Older First  Highest BucketID)
		---------------------------------------------------
		;WITH CTE AS (
			SELECT
				*,
				SUM(BucketQty) OVER (
					PARTITION BY StockItemId 
					ORDER BY BucketID DESC   -- FIFO: older first
				) AS CumIn,
				OutQty AS TotalOut
			FROM #TempBucketQty
		),
		Allocated AS (
			SELECT
				*,
				CASE 
					WHEN TotalOut >= CumIn THEN 0
					WHEN TotalOut < (CumIn - BucketQty) THEN BucketQty
					ELSE BucketQty - (TotalOut - (CumIn - BucketQty))
				END AS RemainingQty
			FROM CTE
		)
		UPDATE T
		SET T.BucketQty = A.RemainingQty
		FROM #TempBucketQty T
		JOIN Allocated A
			ON T.StockItemId = A.StockItemId
		   AND T.BucketID = A.BucketID;

		---------------------------------------------------
		-- Final Result
		---------------------------------------------------
		SELECT TBQ.*,'' AS Locaion,
		C.Name AS Category, S.Name AS SubCategory, u.Name AS MasterUnit 
		FROM #TempBucketQty TBQ
		INNER JOIN StockItemHeaders H ON H.Id = TBQ.StockItemId
		INNER JOIN dbo.Categories AS C WITH (NOLOCK) ON C.Id = H.CategoryID
		INNER JOIN dbo.SubCategories AS S WITH (NOLOCK) ON S.Id = H.SubCategoryID
		--INNER JOIN dbo.Locations AS L WITH (NOLOCK) ON L.Id = TBQ.LocationID
		--INNER JOIN #UserLocation AS UL ON UL.LocationID = L.Id
		INNER JOIN dbo.Units AS U WITH (NOLOCK) ON U.Id = TBQ.MasterUnitID
		ORDER BY TBQ.StockItemId, TBQ.BucketID;		
	END
END;

GO

