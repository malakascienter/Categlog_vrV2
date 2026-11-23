
--  [dbo].[SP_RPT_ItemAgeDaysAnalysis] -999,'2024/04/03',-999,-999,-999,4168,1

create PROCEDURE [dbo].[SP_RPT_ItemAgeDaysAnalysis]( @StockItemID INT =-999,  @Date DATE='2021-03-03',
@CategoryID INT= -999, @SubcategoryID INT= -999 , @LocationID INT= 4, @UserID int =1,@PropertyID INT = -999)

AS
BEGIN
	CREATE TABLE #UserLocation (LocationID INT )

	INSERT INTO #UserLocation
			( LocationID )
	SELECT [LocationID] FROM UserWise_Location
	WHERE UserID= @UserID

	----drop table AAdata
	--select @StockItemID item,@LocationID loc,@PropertyID pro, @CategoryID cat into AAdata

	--select * from AAdata


	 SELECT DISTINCT   D.StockItemId, D.QuantityInHand, l.Id LocationID,h.StockItemCode,
	--CAST(CONVERT(varchar, CAST([dbo].[GetAvaragePriceAsAtDate](@Date,h.Id,d.LocationID,0) AS DECIMAL(18,6)), 1) AS varchar) AS AvaragePrice,
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,0) AS DECIMAL(18,6)), 1) AS varchar) AS Quantity, 
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,1) AS DECIMAL(18,6)), 1) AS varchar) AS value ,
	CAST(0 AS DECIMAL(18,6)) AS StockAgeQty
	INTO #TempStockBalance
	FROM dbo.StockItemDetails AS D 
	INNER JOIN dbo.StockItemHeaders AS H ON (H.Id = d.StockItemHeaderID) --AND h.LocationId = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END)
	INNER JOIN dbo.Locations l ON l.Id = D.LocationID
	INNER JOIN StockTransactionDetails TD ON TD.StockItemID = H.Id AND TD.TxnType = 'P'
	INNER JOIN StockTransactionHeaders TH ON Th.Id = TD.StockTransactionHeaderID AND TH.TransactionType IN ('GR','TI','AA')
	WHERE d.LocationID = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END
	AND  h.CategoryID = CASE @CategoryID WHEN -999 THEN h.CategoryId ELSE @CategoryId END 
	AND h.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN h.SubCategoryID ELSE @SubcategoryID END 
	AND h.Id = CASE @StockItemID WHEN -999 THEN h.Id ELSE @StockItemID END 
	AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END 
	AND D.IsActive = 1 AND D.QuantityInHand > 0
	 AND CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,1) AS DECIMAL(18,6)), 1) AS DECIMAL(18,6)) > 0 
	

	DECLARE @STockItem INT,@TxnId INT,@Location INT, @QTyInHand DECIMAL(18,6), @Quantity DECIMAL(18,6),@StockAgeQty DECIMAL(18,6)

	CREATE TABLE #TempData(
	StockItemId INT,
	ItemName VARCHAR(500),
	ItemCode VARCHAR(300),
	Unit VARCHAR(300),
	Quantity DECIMAL(18,6),
	NoOfDays int,
	QtyInHand DECIMAL(18,6),
	LocationId INT,
	TXNTyp VARCHAR(200),
	TransactionDate varchar(25),
	CatName VARCHAr(300),
	SubCatName VARCHAR(300),
	Location VARCHAR(300),
	AgeCategory VARCHAR(300),
	LastGRNSupplier VARCHAR(MAX),
	ItemAge DECIMAL(18,2)
	)

	CREATE TABLE #AgeBreakDown(
	Id INT,
	TypeName VARCHAR(500),
	FromVal int,
	ToVal int
	)

	INSERT INTO #AgeBreakDown (
    Id,
    TypeName,
    FromVal,
	ToVal
)
VALUES
    (
        1,
        '0 to 40 Days',
        0,
		40
    ),
    (
       2,
        '41 to 80 Days',
        41,
		80
    ),
	(
        3,
        'More than 80 Days',
        81,
		50000 
    );

	
	WHILE(SELECT COUNT(*) FROM #TempStockBalance WHERE CAST(QuantityInHand AS DECIMAL(18,6)) > CAST(StockAgeQty AS DECIMAL(18,6)))>0
	BEGIN
	
		SELECT TOP(1) @STockItem = Stockitemid, @Location = LocationID,@QTyInHand = QuantityInHand,@StockAgeQty = StockAgeQty FROM #TempStockBalance
		WHERE CAST(QuantityInHand AS DECIMAL(18,6)) > CAST(StockAgeQty AS DECIMAL(18,6))

		
		SELECT DISTINCT TH.TransactionDate,  TD.Quantity,TD.id, TD.StockItemID, TH.TransactionType,0 AS StockAgeQty,[dbo].[FN_GetLastGRNSupplier](@Location,@STockItem,@Date) LastGRNSupplier
		INTO #TempTxnData  FROM StockTransactionHeaders TH
		INNER JOIN StockTransactionDetails TD ON TH.Id = TD.StockTransactionHeaderID
		WHERE TH.TransactionType IN ('GR','TI','AA') AND TD.StockItemID = @STockItem AND TH.LocationID = @Location AND TH.PropertyID = CASE WHEN @PropertyID = -999 THEN TH.PropertyID ELSe @PropertyID END
		AND TD.TxnType = 'P' 
		ORDER BY TH.TransactionDate DESC

		print convert(time, getdate())

		WHILE(CAST(@StockAgeQty AS DECIMAL(18,6)) < CAST(@QTyInHand AS DECIMAL(18,6)) AND (SELECT COUNT(*) FROM #TempTxnData ) >0)
		BEGIN

			SELECT TOP(1) @Quantity = Quantity,@TxnId = Id FROM #TempTxnData ORDER BY TransactionDate DESC

			SELECT TOP(1)  @StockAgeQty = StockAgeQty FROM #TempStockBalance  WHERE CAST(QuantityInHand AS DECIMAL(18,6)) > CAST(StockAgeQty AS DECIMAL(18,6))
			AND LocationID = @Location AND StockItemId = @STockItem

			SET @StockAgeQty = @Quantity + @StockAgeQty

			UPDATE #TempStockBalance
			SET StockAgeQty = @StockAgeQty
			WHERE StockItemId = @STockItem AND LocationID = @Location

			INSERT INTO #TempData(StockItemId,Quantity ,NoOfDays,QtyInHand,LocationId,TXNTyp,TransactionDate,ItemName,ItemCode,Unit,CatName, SubCatName,Location,AgeCategory,LastGRNSupplier,ItemAge)
			SELECT TOP(1) txn.StockItemID,Quantity,DATEDIFF(DAY, txn.TransactionDate, GETDATE()) NoOfDays,
			@QTyInHand,l.id,CASE WHEN TransactionType = 'GR' THEN 'Good Receive Note' WHEN TransactionType = 'TI' THEN 'Transfer In' WHEN TransactionType = 'AA'
			THEN 'Reconciliation' END,txn.TransactionDate,h.Name,H.StockItemCode,u.Name,c.Name,s.Name,l.Name,(select TypeName from #AgeBreakDown where 
			FromVal<= DATEDIFF(DAY, txn.TransactionDate, GETDATE()) 
			AND ToVal>= DATEDIFF(DAY, txn.TransactionDate, GETDATE())) AS AgeCategory,
			txn.LastGRNSupplier, D.ItemAge
			FROM #TempTxnData txn
			Inner join dbo.StockItemDetails AS D on txn.StockItemID =D.StockItemHeaderID
			INNER JOIN dbo.StockItemHeaders AS H ON (H.Id = d.StockItemHeaderID)
			INNER JOIN dbo.Categories c ON c.id= h.CategoryID 
			INNER JOIN dbo.SubCategories s ON s.Id = h.SubCategoryID
			INNER JOIN dbo.Locations l ON l.Id = D.LocationID
			INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
			INNER JOIN dbo.Units u ON u.Id = D.MasterUnitID
			ORDER BY TransactionDate DESC
			
			DELETE FROM #TempTxnData WHERE id = @TxnId
	
			
		END

		DROP TABLE #TempTxnData

	END
	
	SELECT DISTINCT * FROM #TempData
	

END

GO

