
 --   [dbo].[SP_RPT_StockBalanceg_BatchWise] '2025-04-11',-999,-999,-999,-999,4168,0,2

 --go
CREATE PROCEDURE [dbo].[SP_RPT_StockBalanceg_BatchWise] ( @Date DATE='2018-08-01', @StockItemID INT =59, 

@CategoryID INT= -999, @SubcategoryID INT= -999 , @LocationID INT= 0, @UserID int =1, @Iszerobalance INT = 1,@PropertyID INT = 1)
as


IF OBJECT_ID('tempdb..#TempTodayConsumption') IS NOT NULL
	DROP TABLE #TempTodayConsumption
CREATE TABLE #TempTodayConsumption(StockItemCode VARCHAR(200),IssueQty DECIMAL(18,8),description VARCHAR(100),StockLocationID INT,BatchNo VARCHAR(200), ExpiryDate DATE)


IF OBJECT_ID('tempdb..#UserLocation') IS NOT NULL
	DROP TABLE #UserLocation
CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID


	INSERT INTO #TempTodayConsumption(StockItemCode,IssueQty,description,StockLocationID,BatchNo,ExpiryDate)
	SELECT SH.StockItemCode,SUM(Quantity) -SUM(ReturnQuantity)  AS IssueQty,LO.Name description,LO.Id StockLocationID,PD.BatchNo,CONVERT(DATE,PD.ExpiryDate)ExpiryDate
	from POS_InvoiceDetail PD
	INNER JOIN StockItemHeaders SH ON PD.ItemID = SH.Id
	INNER JOIN Locations LO ON LO.Id = PD.LocationID 
	where BusinessDate= CONVERT(DATE,@Date) 
	AND LO.ID = CASE WHEN @LocationID =-999 THEN LO.Id ELSE @LocationID END
	AND SH.Id = CASE WHEN @StockItemID = -999 THEN SH.Id ELSE @StockItemID END
	AND PD.CompanyID = CASE WHEN @PropertyID = -999 THEN PD.CompanyID ELSE @PropertyID END
	GROUP BY  SH.StockItemCode, LO.Name,LO.Id ,PD.BatchNo,PD.ExpiryDate

	--SELECT *
	--FROM #TempTodayConsumption


 SELECT Co.Name AS CompanyName, D.QuantityInHand, l.Name Location,l.Id LocationID,h.StockItemCode, h.Name, c.Name categoryname, s.Name subcatergoryname ,sb.Description AS SubCat2Name, u.name AS unitname,
	CAST(CONVERT(varchar, CAST([dbo].[GetAvaragePriceAsAtDate](@Date,h.Id,d.LocationID,0) AS DECIMAL(18,6)), 1) AS varchar) AS AvaragePrice,
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,0) AS DECIMAL(18,6)), 1) AS varchar) AS Quantity, 
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,1) AS DECIMAL(18,6)), 1) AS varchar) AS value  
	,H.Id ItemID
	INTO #TempStockBalance
	FROM dbo.StockItemDetails AS D 
	INNER JOIN dbo.StockItemHeaders AS H WITH (NOLOCK) ON (H.Id = d.StockItemHeaderID) --AND h.LocationId = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END)
	INNER JOIN dbo.Categories c  WITH (NOLOCK) ON c.id= h.CategoryID 
	INNER JOIN dbo.SubCategories s  WITH (NOLOCK) ON s.Id = h.SubCategoryID
	INNER JOIN SubCategories02 sb  WITH (NOLOCK) ON sb.Id = h.SubCategory2ID
	INNER JOIN dbo.Locations l  WITH (NOLOCK) ON l.Id = D.LocationID
	INNER JOIN #UserLocation ul  WITH (NOLOCK)  ON ul.LocationID = l.Id
	INNER JOIN dbo.Units u  WITH (NOLOCK) ON u.Id = d.MasterUnitID
	INNER JOIN Companies Co  WITH (NOLOCK) ON Co.CompanyID = D.PropertyID
	WHERE d.LocationID = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END
	AND  h.CategoryID = CASE @CategoryID WHEN -999 THEN h.CategoryId ELSE @CategoryId END 
	AND h.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN h.SubCategoryID ELSE @SubcategoryID END 
	AND h.Id = CASE @StockItemID WHEN -999 THEN h.Id ELSE @StockItemID END 
	AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END
	AND D.IsActive = 1 -- dont remove by loku aruna ayya 2-24-02-8 for araliya groups
	ORDER BY d.LastModDate desc 
	--select * from #TempStockBalance

	SELECT ST.StockItemID ItemID,ST.LocationID LocationID,ST.BatchNo,CONVERT(DATE,ST.EXPDate) EXPDate
	,([dbo].[FN_GetBatchBalanceQty](ST.StockItemID,ST.LocationID,ST.BatchNo,ST.EXPDate,@Date)  - TT.IssueQty )BalanceQty
	,ISNULL(ST.SellingPrice,0) SellingPrice
	INTO #TempEX
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN #TempStockBalance SIH ON SIH.ItemID = SD.StockItemID
	INNER JOIN StockItemWiseEXPDateIns ST ON ST.TransactionID = SH.Id AND ST.StockItemID = SD.StockItemID
	LEFT JOIN #TempTodayConsumption TT ON TT.StockItemCode =SIH.StockItemCode AND SIH.LocationID = TT.StockLocationID AND TT.BatchNo = ST.BatchNo AND CONVERT(DATE,TT.ExpiryDate)= CONVERT(DATE,ST.EXPDate)
	GROUP BY ST.BatchNo,ST.EXPDate,ST.StockItemID,ST.LocationID,ST.SellingPrice,TT.IssueQty


	--SELECT *
	--FROM #TempEX

	IF @Iszerobalance = 0
		begin
		SELECT CompanyName, Location,TP.LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, AvaragePrice,BalanceQty  Quantity,
		TX.BatchNo,TX.EXPDate, (BalanceQty * AvaragePrice) Value,TP.ItemID,SellingPrice
		FROM #TempStockBalance TP
		INNER JOIN #TempEX TX ON TP.ItemID = TX.ItemID AND TP.LocationID = TX.LocationID
		WHERE  cast(value as decimal(18,6)) <> 0 
		ORDER BY StockItemCode ASC,Name ASC,TP.LocationID DESC, categoryname ASC, subcatergoryname ASC
		end
	ELSE 
			SELECT CompanyName, Location,TP.LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, AvaragePrice,BalanceQty  Quantity,
		TX.BatchNo,TX.EXPDate, (BalanceQty * AvaragePrice) Value,TP.ItemID,SellingPrice
		FROM #TempStockBalance TP
		INNER JOIN #TempEX TX ON TP.ItemID = TX.ItemID AND TP.LocationID = TX.LocationID
			ORDER BY StockItemCode ASC,Name ASC,TP.LocationID DESC, categoryname ASC, subcatergoryname ASC

GO

