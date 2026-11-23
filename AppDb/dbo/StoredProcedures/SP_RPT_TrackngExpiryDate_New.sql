
 --   [dbo].[SP_RPT_TrackngExpiryDate_New] -999,-999,-999,-999,11,1,'2020-08-01','2030-12-01'

 --go
CREATE PROCEDURE [dbo].[SP_RPT_TrackngExpiryDate_New] (@StockItemID INT =-999, 
@CategoryID INT= -999, @SubcategoryID INT= -999 , @LocationID INT= -999, @UserID int =1,@PropertyID INT = 1,@DateFrom DATE='2020/08/01', @DateTo DATE='2030/12/01' )
as

CREATE TABLE #UserLocation (LocationID INT )

	DECLARE @ExpStockItemID INT,@ExpLocationID INT
	DECLARE @ProcessedQty MONEY= 0, @ID INT , @BalanceQuantity MONEY , @EXPDate DATE, @TransactionType varchar(50), @ThisQty  MONEY 
	,@LocationID2 INT,@Date DATE='2018-08-01'

	SET @Date = CONVERT(DATE,GETDATE())


	IF OBJECT_ID('tempdb..#TempItem') IS NOT NULL
	DROP TABLE #TempItem
	CREATE TABLE #TempItem (Quantity DECIMAL(18,8), BalanceQuantity DECIMAL(18,8), EXPDate DATE,StockItemID INT,TransactionType VARCHAR(100),ID INT,TransactionID INT);

	IF OBJECT_ID('tempdb..#TempStockBalance') IS NOT NULL
	DROP TABLE #TempStockBalance
	CREATE TABLE #TempStockBalance (ItemID INT, Quantity DECIMAL(18,8),LocationID INT, ItemName  VARCHAR(500));

	IF OBJECT_ID('tempdb..#ExpDateStock') IS NOT NULL
	DROP TABLE #ExpDateStock
	CREATE TABLE #ExpDateStock (Quantity DECIMAL(18,8),BalanceQuantity DECIMAL(18,8), EXPDate DATETIME ,StockItemID INT ,LocationID INT ,TransactionType VARCHAR(100),ID INT,TransactionID INT);


INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID
 
	INSERT INTO #TempStockBalance(ItemID,Quantity,LocationID,ItemName) 
	SELECT
	H.ID ItemID,CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,0) AS DECIMAL(18,6)), 1) AS varchar) AS Quantity,d.LocationID,H.NAME  ItemName
	FROM dbo.StockItemDetails AS D 
	INNER JOIN dbo.StockItemHeaders AS H ON (H.Id = d.StockItemHeaderID) --AND h.LocationId = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END)
	INNER JOIN dbo.Categories c ON c.id= h.CategoryID 
	INNER JOIN dbo.SubCategories s ON s.Id = h.SubCategoryID
	INNER JOIN SubCategories02 sb ON sb.Id = h.SubCategory2ID
	INNER JOIN dbo.Locations l ON l.Id = D.LocationID
	INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
	INNER JOIN dbo.Units u ON u.Id = d.MasterUnitID
	INNER JOIN Companies Co ON Co.CompanyID = D.PropertyID
	WHERE d.LocationID = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END
	AND  h.CategoryID = CASE @CategoryID WHEN -999 THEN h.CategoryId ELSE @CategoryId END 
	AND h.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN h.SubCategoryID ELSE @SubcategoryID END 
	AND h.Id = CASE @StockItemID WHEN -999 THEN h.Id ELSE @StockItemID END 
	AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END --AND D.IsActive = 1 COMMENTED BY ISURU
	ORDER BY d.LastModDate desc 

	--select * from #TempStockBalance  WHERE  cast(Quantity as decimal(18,6)) > 0 

	WHILE EXISTS(SELECT 1 FROM #TempStockBalance WHERE  cast(Quantity as decimal(18,6)) > 0 )
	BEGIN

	SELECT TOP(1) @ExpStockItemID = ItemID ,@ProcessedQty = Quantity, @LocationID2 = LocationID  FROM #TempStockBalance WHERE  cast(Quantity as decimal(18,6)) > 0 

	IF EXISTS(SELECT 1 FROM StockItemWiseEXPDateIns WHERE StockItemID = @ExpStockItemID AND LocationID = @LocationID2)
	BEGIN
		INSERT INTO #ExpDateStock(Quantity,BalanceQuantity, EXPDate,StockItemID,LocationID,TransactionType,ID,TransactionID)
		SELECT Quantity,Quantity BalanceQuantity, EXPDate,StockItemID,LocationID,TransactionType,ID,TransactionID
		FROM StockItemWiseEXPDateIns
		WHERE LocationID = @LocationID2
		AND TransactionType NOT IN ('IN','II','TO')
		AND StockItemID=@ExpStockItemID
		AND EXPDate BETWEEN @DateFrom AND @DateTo 
		AND LocationID = @LocationID2
		ORDER BY EXPDate DESC

		

		WHILE (@ProcessedQty>0)
		BEGIN
		
		SELECT TOP (1)@ID =ID,@BalanceQuantity = BalanceQuantity FROM #ExpDateStock ORDER BY EXPDate DESC

		--SELECT *
		--FROM #ExpDateStock
		--WHERE ID =@ID
		

		--sELECT @ProcessedQty ProcessedQty,@BalanceQuantity BalanceQuantity 

		UPDATE #ExpDateStock
		SET BalanceQuantity = CASE WHEN @ProcessedQty < BalanceQuantity THEN  @ProcessedQty ELSE BalanceQuantity  END
		WHERE ID =@ID

		INSERT INTO #TempItem(Quantity,BalanceQuantity, EXPDate,StockItemID,TransactionType,ID,TransactionID)
		SELECT Quantity,BalanceQuantity, EXPDate,StockItemID,TransactionType,ID,TransactionID
		FROM #ExpDateStock
		WHERE ID =@ID AND StockItemID=@ExpStockItemID

		SET @ProcessedQty = CASE WHEN @ProcessedQty < @BalanceQuantity THEN 0 ELSE  @ProcessedQty - @BalanceQuantity END

		
		--SELECT @ProcessedQty ProcessedQty

		DELETE TOP (1) FROM #ExpDateStock  FROM #ExpDateStock WHERE ID =@ID
		END


		
	END


	DELETE TOP (1) FROM #TempStockBalance WHERE  cast(Quantity as decimal(18,6)) > 0  
		

	END

			
	--SELECT*
	--FROM #TempItem TP

	SELECT DISTINCT TP.StockItemID,LO.Name LocationName,SIH.StockItemCode,SIH.Name ItemName,UN.Name UnitName,SUM(TP.BalanceQuantity) BalanceQuantity,TP.EXPDate
	--TP.Quantity,TP.BalanceQuantity, TP.EXPDate,TP.StockItemID,TP.TransactionType,TP.ID,TP.TransactionID
	FROM #TempItem TP
	INNER JOIN STOCKITEMHEADERS SIH ON TP.StockItemID = SIH.ID
	INNER JOIN StockTransactionHeaders SH ON SH.Id = TP.TransactionID
	INNER JOIN StockTransactionDetails SD ON SD.StockTransactionHeaderID =  SH.Id AND SD.StockItemID = TP.StockItemID
	INNER JOIN UNITS UN ON UN.ID = SD.TxnUnitID
	INNER JOIN LOCATIONS LO ON LO.ID = SH.LocationID
	WHERE EXPDate BETWEEN @DateFrom AND @DateTo 
	AND TP.BalanceQuantity >0
	GROUP BY TP.StockItemID,LO.Name,SIH.StockItemCode,SIH.Name,UN.Name,TP.EXPDate
	ORDER BY StockItemCode,TP.EXPDate DESC

GO

