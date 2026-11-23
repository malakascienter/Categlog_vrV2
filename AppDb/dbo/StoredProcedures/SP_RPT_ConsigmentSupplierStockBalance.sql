
 --   [dbo].[SP_RPT_ConsigmentSupplierStockBalance] '2024-06-27',-999,-999,-999,-999,4168,1,-999,-999

 --go
CREATE PROCEDURE [dbo].[SP_RPT_ConsigmentSupplierStockBalance] ( @Date DATE='2018-08-01', @StockItemID INT =59, 
@CategoryID INT= -999, @SubcategoryID INT= -999 , @LocationID INT= 0, @UserID int =1, @Iszerobalance INT = 1,@PropertyID INT = 1,@SupplierID INT)
as

CREATE TABLE #UserLocation (LocationID INT )

INSERT INTO #UserLocation
        ( LocationID )
SELECT [LocationID] FROM UserWise_Location
WHERE UserID= @UserID
 
 SELECT Co.Name AS CompanyName, D.QuantityInHand, l.Name Location,l.Id LocationID,h.StockItemCode, h.Name, c.Name categoryname, s.Name subcatergoryname ,sb.Description AS SubCat2Name, u.name AS unitname,
	CAST(CONVERT(varchar, CAST([dbo].[GetAvaragePriceAsAtDate](@Date,h.Id,d.LocationID,0) AS DECIMAL(18,6)), 1) AS varchar) AS AvaragePrice,
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,0) AS DECIMAL(18,6)), 1) AS varchar) AS Quantity, 
	CAST(CONVERT(varchar, CAST([dbo].[GetBalance](@Date,h.Id,d.LocationID,0,1) AS DECIMAL(18,6)), 1) AS varchar) AS value  
	,SUP.Name SupplierName
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
	INNER JOIN SupplierWiseItemDetails SUI ON SUI.StockItemID = H.Id AND SUI.LocationId = L.Id
	INNER JOIN Suppliers SUP ON SUP.ID = SUI.SupplierID AND SUP.IsConsigments=1
	WHERE d.LocationID = CASE @LocationID WHEN -999 THEN d.LocationID ELSE @LocationID END
	AND  h.CategoryID = CASE @CategoryID WHEN -999 THEN h.CategoryId ELSE @CategoryId END 
	AND h.SubCategoryID = CASE @SubcategoryID WHEN -999 THEN h.SubCategoryID ELSE @SubcategoryID END 
	AND h.Id = CASE @StockItemID WHEN -999 THEN h.Id ELSE @StockItemID END 
	AND D.PropertyID = CASE WHEN @PropertyID = -999 THEN D.PropertyID ELSE @PropertyID END --AND D.IsActive = 1 COMMENTED BY ISURU
	--AND SUI.SupplierID =CASE WHEN @SupplierID = -999 THEN SUI.SupplierID ELSE @SupplierID END 
	ORDER BY d.LastModDate desc 
	
	IF @Iszerobalance = 0
		begin
		SELECT CompanyName, Location,LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, AvaragePrice, Quantity,Value,SupplierName
		FROM #TempStockBalance WHERE  cast(value as decimal(18,6)) > 0 
		ORDER BY StockItemCode ASC,Name ASC,LocationID DESC, categoryname ASC, subcatergoryname ASC
		end
	ELSE 
		SELECT  CompanyName,Location,LocationID,StockItemCode,Name,categoryname,subcatergoryname,SubCat2Name,unitname, AvaragePrice, Quantity,Value,SupplierName 
		FROM #TempStockBalance 
		ORDER BY StockItemCode ASC,Name ASC,LocationID DESC, categoryname ASC, subcatergoryname ASC

GO

