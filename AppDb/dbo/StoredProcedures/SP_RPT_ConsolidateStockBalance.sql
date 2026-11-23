
 --   [dbo].[SP_RPT_NewStockBalanceg] -999,-999,-999,-999,5485,0,1
 --go
CREATE PROCEDURE [dbo].[SP_RPT_ConsolidateStockBalance] (@StockItemID INT =59, 
@CategoryID INT= -999, @SubcategoryID INT= -999 , @LocationID INT= 0, @UserID int =1, @Iszerobalance INT = 1,@PropertyID INT = 1)
as

DECLARE  @Date DATE,@OutletCode CHAR(3)

SELECT @Date = ISNULL([dbo].[FN_GetCurrentDate](@PropertyID,@LocationID),GETDATE())

IF OBJECT_ID('tempdb..#Outlets') IS NOT NULL
	DROP TABLE #Outlets
CREATE TABLE #Outlets (Code CHAR(3) );

IF OBJECT_ID('tempdb..#TempTodayConsumption') IS NOT NULL
	DROP TABLE #TempTodayConsumption
CREATE TABLE #TempTodayConsumption(StockItemCode VARCHAR(200),IssueQty DECIMAL(18,8),description VARCHAR(100),StockLocationID INT)

IF OBJECT_ID('tempdb..#UserLocation') IS NOT NULL
	DROP TABLE #UserLocation
CREATE TABLE #UserLocation (LocationID INT )


INSERT INTO #Outlets( Code )
SELECT Code
FROM Location_Ref
WHERE StockLocationID = CASE @LocationID WHEN -999 THEN StockLocationID ELSE @LocationID END



INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID

INSERT INTO #TempTodayConsumption(StockItemCode,IssueQty,description,StockLocationID)
SELECT	  SH.StockItemCode, SUM(RD.Qty * IB.Qty * BT.Qty) AS IssueQty, LR.description,LR.StockLocationID
FROM	RecipeDetails AS RD INNER JOIN RecipeHeader AS RH ON RD.RecipeCode = RH.RecipeCode AND RD.PropertyId = RH.PropertyId 
INNER JOIN ItemBreakDown AS IB ON RH.RecipeCode = IB.RecipeCode AND IB.PropertyId = RH.PropertyId 
INNER JOIN BillTrans AS BT ON IB.MainMenuCode = BT.MainMenuCode AND BT.PropertyId = IB.PropertyId 
INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
INNER JOIN StockItemDetails AS SD ON RD.StockItemCode = SD.StockItemHeaderID AND SD.PropertyID = BT.PropertyId AND SD.LocationID = LR.StockLocationID
INNER JOIN STOCKITEMHEADERS SH ON SH.ID = SD.StockItemHeaderID
WHERE	BT.PropertyId = CASE WHEN @PropertyID = -999 THEN BT.PropertyId ELSE @PropertyID END 
AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@Date) 
AND LR.code IN(SELECT Code FROM #Outlets) 
GROUP BY  SH.StockItemCode, LR.description,LR.StockLocationID
UNION ALL -- Union to find One to one mapping items consumptions
SELECT 	SH.StockItemCode, SUM(BT.Qty) AS IssueQty, LR.description,LR.StockLocationID
FROM	BillTrans AS BT 
		INNER JOIN MainMenu MM ON BT.MainMenuCode = MM.ItemCode AND BT.PropertyId = MM.PropertyId
		INNER JOIN Location_Ref AS LR ON BT.Outlet = LR.code AND LR.PropertyId = BT.PropertyId 
		INNER JOIN StockItemDetails AS SD ON MM.StockItemId = SD.StockItemHeaderID AND MM.PropertyID = SD.PropertyId AND SD.LocationID = LR.StockLocationID
		INNER JOIN STOCKITEMHEADERS SH ON SH.ID = SD.StockItemHeaderID
WHERE	BT.PropertyId =  @PropertyId AND CONVERT(DATE, BT.OrderDate) =  CONVERT(DATE,@Date) and LR.Code IN(SELECT Code FROM #Outlets) 
GROUP BY  SH.StockItemCode, LR.description,LR.StockLocationID
 

--SELECT *
--FROM #TempTodayConsumption
 
 SELECT Co.Name AS CompanyName, D.QuantityInHand, l.Name Location,l.Id LocationID,h.StockItemCode, h.Name, c.Name categoryname, s.Name subcatergoryname ,sb.Description AS SubCat2Name, u.name AS unitname,
	CAST(CONVERT(varchar, CAST([dbo].[GetAvaragePriceAsAtDate](@Date,h.Id,d.LocationID,0) AS DECIMAL(18,6)), 1) AS varchar) AS AvaragePrice,
	CONVERT(decimal(18,6) ,CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,0) AS DECIMAL(18,6)), 1) AS varchar) )AS Quantity, 
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,1) AS DECIMAL(18,6)), 1) AS varchar) AS value 
	--,0 AS TodayConsumption
	,[dbo].[FN_GetLastGRNSupplier](l.Id,H.Id,@Date) LastSupplier
	,ISNULL(TC.IssueQty,0) TodayConsumption
	INTO #TempStockBalance
	FROM dbo.StockItemDetails AS D 
	INNER JOIN dbo.StockItemHeaders AS H ON (H.Id = d.StockItemHeaderID) --AND h.LocationId = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END)
	INNER JOIN dbo.Categories c ON c.id= h.CategoryID 
	INNER JOIN dbo.SubCategories s ON s.Id = h.SubCategoryID
	INNER JOIN SubCategories02 sb ON sb.Id = h.SubCategory2ID
	INNER JOIN dbo.Locations l ON l.Id = D.LocationID
	INNER JOIN #UserLocation ul ON ul.LocationID = l.Id
	INNER JOIN dbo.Units u ON u.Id = d.MasterUnitID
	INNER JOIN Companies Co ON Co.CompanyID = D.PropertyID
	LEFT JOIN #TempTodayConsumption TC ON TC.StockItemCode = H.StockItemCode AND TC.StockLocationID = l.Id
	WHERE d.LocationID = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END
	AND  h.CategoryID = CASE @CategoryID WHEN -999 THEN h.CategoryId ELSE @CategoryId END 
	AND h.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN h.SubCategoryID ELSE @SubcategoryID END 
	AND h.Id = CASE @StockItemID WHEN -999 THEN h.Id ELSE @StockItemID END 
	AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END AND D.IsActive = 1
	ORDER BY d.LastModDate desc 

	--SELECT * FROM #TempStockBalance
	
	IF @Iszerobalance = 0
		begin
		SELECT CompanyName, Location,LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, AvaragePrice, Quantity,Value,TodayConsumption,LastSupplier
		FROM #TempStockBalance WHERE  cast(value as decimal(18,6)) <> 0 
		ORDER BY StockItemCode ASC,LocationID DESC, categoryname ASC, subcatergoryname ASC
		end
	ELSE 
		SELECT  CompanyName,Location,LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, AvaragePrice, Quantity,Value,TodayConsumption,LastSupplier
		FROM #TempStockBalance 
		ORDER BY StockItemCode ASC,LocationID DESC, categoryname ASC, subcatergoryname ASC

GO

