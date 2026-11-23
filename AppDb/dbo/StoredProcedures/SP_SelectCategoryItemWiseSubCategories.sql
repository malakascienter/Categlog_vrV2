CREATE PROCEDURE [dbo].[SP_SelectCategoryItemWiseSubCategories](@CategoryId INT, @PropertyID INT)
	
AS
BEGIN
	SELECT DISTINCT S.Id , s.Name 
	FROM StockItemHeaders H
	INNER JOIN StockItemDetails D ON H.Id = D.StockItemHeaderID
	INNER JOIN SubCategories S ON S.Id = H.SubCategoryID
	WHERE H.CategoryID = CASE WHEN @CategoryId = 0 THEN  H.CategoryID WHEN  @CategoryId = -999 THEN  H.CategoryID  ELSE @CategoryId END
	AND D.IsActive = 1 AND H.CompanyId = CASE WHEN @PropertyID = -999 THEN H.CompanyId ELSE @PropertyID END

END

GO

