-- [dbo].[SP_SelectSubCat2WiseItems] 1,-999,-999,-999,-999

CREATE PROCEDURE [dbo].[SP_SelectSubCat2WiseItems](@CompanyId INT,@LocationId INT,@CategoryID INT, @subcategoryID INT, @subcategory2ID INT = -999)
AS
BEGIN
	SELECT	DISTINCT h.companyid, H.Id, H.Name AS text  FROM StockItemHeaders H WITH(NOLOCK)
	INNER JOIN StockItemDetails D WITH(NOLOCK) ON H.Id = D.StockItemHeaderID
	WHERE H.CompanyId = CASE WHEN @CompanyId  = -999 THEN H.CompanyId ELSE @CompanyId END
	AND H.CategoryID = CASE WHEN @CategoryID = -999 THEN H.CategoryID ELSE @CategoryID END 
	AND H.SubCategoryID = CASE WHEN @subcategoryID = -999 THEN H.SubCategoryID ELSE @subcategoryID END
	AND H.SubCategory2ID = CASE WHEN @subcategory2ID = -999 THEN H.SubCategory2ID ELSE @subcategory2ID END 
	AND D.LocationID = CASE WHEN @LocationId = -999 THEN D.LocationID ELSE @LocationId END
END

GO

