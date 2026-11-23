CREATE PROCEDURE [dbo].[SelectSubCategory]
AS
BEGIN
	SELECT DISTINCT sc.Id,sc.Code,sc.Name
	FROM SubCategories sc
	INNER JOIN StockItemHeaders s ON sc.Id = s.SubCategoryID
END

GO

