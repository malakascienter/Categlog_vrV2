
 --   [dbo].[SP_RPT_StockBalanceg] '2025-10-01',2464,-999,-999,35,5485,1,2

 --go
CREATE PROCEDURE [dbo].[SP_RPT_StockBalanceg] ( @Date DATE='2018-08-01', @StockItemID INT =59, 
@CategoryID INT= -999, @SubcategoryID INT= -999 , @LocationID INT= 0, @UserID int =1, @Iszerobalance INT = 1,@PropertyID INT = 1)
as

CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location WITH (NOLOCK)
WHERE UserID= @UserID
AND CompanyId = CASE WHEN @PropertyID = -999 THEN CompanyId ELSE  @PropertyID END

CREATE TABLE #TempStockBalance (
    CompanyName        NVARCHAR(200),
    QuantityInHand     DECIMAL(18,6),
    Location           NVARCHAR(200),
    LocationID         INT,
    StockItemCode      NVARCHAR(MAX),
    Name               NVARCHAR(MAX),
    categoryname       NVARCHAR(MAX),
    subcatergoryname    NVARCHAR(MAX),
    SubCat2Name        NVARCHAR(MAX),
    unitname           NVARCHAR(MAX),
    AvaragePrice       DECIMAL(18,6),
    Quantity           DECIMAL(18,6),
    Value              DECIMAL(18,6)
);

	;WITH LatestBalance AS
		(
		SELECT
			D.StockItemID,
			H.LocationID,
			D.NewQuantity,
			D.NewAveragePrice,
			ROW_NUMBER() OVER (
				PARTITION BY D.StockItemID, H.LocationID
				ORDER BY H.TransactionDate DESC, H.CreatedDate DESC
			) AS rn
		FROM StockTransactionDetails D
		JOIN StockTransactionHeaders H 
			ON D.StockTransactionHeaderID = H.Id
		WHERE H.TransactionDate <= @Date
		)
		SELECT
		StockItemID,
		LocationID,
		NewQuantity AS BalanceQty,
		NewAveragePrice AS AvgPrice,
		(NewQuantity * NewAveragePrice) AS BalanceVal
		INTO #LatestBalance
		FROM LatestBalance
		WHERE rn = 1;


 
 INSERT INTO #TempStockBalance (CompanyName, QuantityInHand, Location, LocationID, StockItemCode, Name,categoryname, subcatergoryname, SubCat2Name, unitname, AvaragePrice,Quantity, Value)
 SELECT Co.Name AS CompanyName, D.QuantityInHand, l.Name Location,l.Id LocationID,h.StockItemCode, h.Name, c.Name categoryname, s.Name subcatergoryname ,sb.Description AS SubCat2Name, u.name AS unitname,
	--Commented by Isuru to call table valued function to fix report timeout issue

	--CAST(CONVERT(varchar, CAST([dbo].[GetAvaragePriceAsAtDate](@Date,h.Id,d.LocationID,0) AS DECIMAL(18,6)), 1) AS varchar) AS AvaragePrice,
	--CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,0) AS DECIMAL(18,6)), 1) AS varchar) AS Quantity, 
	--CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,1) AS DECIMAL(18,6)), 1) AS varchar) AS value 
	BQ.AvgPrice AS AvaragePrice,
	BQ.BalanceQty AS Quantity,
	BQ.BalanceVal AS Value

	--BV.BalanceVal AS Value
	--end 
	FROM dbo.StockItemDetails AS D  WITH (NOLOCK)
	INNER JOIN dbo.StockItemHeaders AS H WITH (NOLOCK) ON (H.Id = d.StockItemHeaderID) --AND h.LocationId = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END)
	INNER JOIN dbo.Categories c  WITH (NOLOCK) ON c.id= h.CategoryID 
	INNER JOIN dbo.SubCategories s  WITH (NOLOCK) ON s.Id = h.SubCategoryID
	INNER JOIN SubCategories02 sb  WITH (NOLOCK) ON sb.Id = h.SubCategory2ID
	INNER JOIN dbo.Locations l  WITH (NOLOCK) ON l.Id = D.LocationID
	INNER JOIN #UserLocation ul  WITH (NOLOCK)  ON ul.LocationID = l.Id
	INNER JOIN dbo.Units u  WITH (NOLOCK) ON u.Id = d.MasterUnitID
	INNER JOIN Companies Co  WITH (NOLOCK) ON Co.CompanyID = D.PropertyID
	
	--added by Isuru to call table valued function to fix report timeout issue
	--OUTER APPLY dbo.GetAveragePriceTVF(@Date,h.Id,d.LocationID,0) AS AP
	--OUTER APPLY dbo.GetBalanceTVF(@Date,h.Id,d.LocationID,0,0) AS BQ
	LEFT JOIN #LatestBalance BQ ON BQ.StockItemID = H.Id AND BQ.LocationID = D.LocationID
	--OUTER APPLY dbo.GetBalanceTVF(@Date,h.Id,d.LocationID,0,1) AS BV

	--end
	WHERE d.LocationID = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END
	AND  h.CategoryID = CASE @CategoryID WHEN -999 THEN h.CategoryId ELSE @CategoryId END 
	AND h.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN h.SubCategoryID ELSE @SubcategoryID END 
	AND h.Id = CASE @StockItemID WHEN -999 THEN h.Id ELSE @StockItemID END 
	AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END
	--AND D.IsActive = 1 -- dont remove by loku aruna ayya 2-24-02-8 for araliya groups
	AND NOT EXISTS (
    SELECT 1
    FROM InactiveStockItemTable I
    WHERE I.StockItemID = H.Id
      AND I.LocationID = D.LocationID
)
	ORDER BY d.LastModDate desc 
	--select * from #TempStockBalance

	IF @Iszerobalance = 0
		begin
		SELECT CompanyName, Location,LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, ISNULL(AvaragePrice,0) AS AvaragePrice, ISNULL(Quantity,0) AS Quantity,ISNULL(Value,0) AS Value
		FROM #TempStockBalance WHERE  cast(value as decimal(18,6)) <> 0 
		ORDER BY Name ASC, categoryname ASC, subcatergoryname ASC, StockItemCode ASC,LocationID DESC
		end
	ELSE 
		SELECT  CompanyName,Location,LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, ISNULL(AvaragePrice,0) AS AvaragePrice, ISNULL(Quantity,0) AS Quantity,ISNULL(Value,0) AS Value
		FROM #TempStockBalance 
		ORDER BY Name ASC,categoryname ASC, subcatergoryname ASC,StockItemCode ASC,LocationID DESC

GO

