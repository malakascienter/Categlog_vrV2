
CREATE PROCEDURE  [dbo].[Price_Change_RPT](@PropertyId INT, @LocationId INT,@CatId INT,@SubCatId INT,@SubCat2Id INT,@StockItemID INT,
@FromDate DATE, @ToDate DATE)

AS
BEGIN
 	SELECT SD.StockItemID,SIH.Name, SIH.StockItemCode,SD.Quantity,SD.UnitPrice, L.Name AS LocationName, C.Name AS CategoryName,
	SC.Name AS SubCatName, SC2.Description AS SubCat2Name,S.Name AS SupplierName, SH.TransactionDate
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	INNER JOIN Categories C ON C.Id = SIH.CategoryID
	INNER JOIN SubCategories SC ON SC.Id = SIH.SubCategoryID
	INNER JOIN SubCategories02 SC2 ON SC2.Id = SIH.SubCategory2ID
	INNER JOIN Locations L ON L.Id = SH.LocationID
	INNER JOIN Suppliers S On S.ID = SH.SupplierID
	WHERE SH.TransactionType = 'GR' AND SH.PropertyID = @PropertyId AND SH.LocationID = CASE WHEN @LocationId = -999 THEN SH.LocationID ELSE @LocationId END
	AND SIH.CategoryID = CASE WHEN @CatId = -999 THEN SIH.CategoryID ELSE @CatId END AND SIH.SubCategoryID = CASE WHEN @SubCatId = -999 THEN SIH.SubCategoryID ELSE @SubCatId END
	AND SIH.SubCategory2ID = CASE WHEN @SubCat2Id = -999 THEN SIH.SubCategory2ID ELSE @SubCat2Id END
	AND SIH.Id = CASE WHEN @StockItemID = -999 THEN SIH.Id ELSE @StockItemID END
	AND SH.TransactionDate BETWEEN @FromDate AND @ToDate

END

GO

