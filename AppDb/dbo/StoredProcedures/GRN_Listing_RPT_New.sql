--   [dbo].[GRN_Listing_RPT_New] -999,-999,-999,-999,-999,-999,-999,'2023/01/01','2025/11/12',3

CREATE PROCEDURE [dbo].[GRN_Listing_RPT_New](@PropertyId INT, @LocationId INT,@CatId INT,@SubCatId INT,@SubCat2Id INT,@StockItemID INT,@SupplierID INT,
@FromDate DATE, @ToDate DATE,@SortOptionID INT)
AS
BEGIN


	--SELECT *
	--FROM ReportSortOption

	SELECT co.Name CompanyName, SD.StockItemID,SIH.Name, SIH.StockItemCode,AVG(SD.UnitPrice) AvgUnitPrice,SUM(SD.Quantity) Quantity, L.Name AS LocationName, C.Name AS CategoryName,
	SC.Name AS SubCatName, SC2.Description AS SubCat2Name,[dbo].[FN_GetLastGRNPrice](L.Id,SIH.Id) LastGRNPrice, [dbo].[FN_GetLastGRNDate](SIH.Id,L.Id,@ToDate) LastGRNDate
	,SH.DocumentNo,SH.TransactionDate,SU.Name SuppName
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	INNER JOIN Categories C ON C.Id = SIH.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID
	INNER JOIN Locations L ON L.Id = SH.LocationID
	INNER JOIN Companies Co ON Co.CompanyID = SH.PropertyID
	INNER JOIN Suppliers SU ON SU.ID = SH.SupplierID
	WHERE SH.TransactionType = 'GR' AND SH.PropertyID = CASE WHEN @PropertyId = -999 THEN SH.PropertyID ELSE @PropertyId END 
	AND SH.LocationID = CASE WHEN @LocationId = -999 THEN SH.LocationID ELSE @LocationId END
	AND SIH.CategoryID = CASE WHEN @CatId = -999 THEN SIH.CategoryID ELSE @CatId END AND SIH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SIH.SubCategoryID ELSE @SubCatId END
	AND SIH.SubCategory2ID = CASE WHEN @SubCat2Id = -999 THEN SIH.SubCategory2ID ELSE @SubCat2Id END
	AND SIH.Id = CASE WHEN @StockItemID = -999 THEN SIH.Id  ELSE @StockItemID END
	AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
	AND SH.SupplierID = CASE WHEN @SupplierID = -999 THEN SH.SupplierID ELSE @SupplierID END
	GROUP BY SD.StockItemID,SIH.Name, SIH.StockItemCode,L.Name, C.Name ,
	SC.Name , SC2.Description,co.Name,L.Id,SIH.Id,SH.DocumentNo,SH.TransactionDate,SU.Name 
	ORDER BY 
	CASE WHEN @SortOptionID =1 THEN SU.Name END ASC,
	CASE WHEN @SortOptionID = 2 THEN SIH.Name END ASC,
	CASE WHEN @SortOptionID = 3 THEN SH.TransactionDate END ASC
	--Co.name DESC
END

GO

