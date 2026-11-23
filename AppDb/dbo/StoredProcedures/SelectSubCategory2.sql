CREATE PROCEDURE [dbo].[SelectSubCategory2]
AS
BEGIN
	SELECT DISTINCT sc.Id,sc.Code,sc.Description
	FROM SubCategories02 sc
	INNER JOIN StockItemHeaders s ON sc.Id = s.SubCategory2ID
END

GO

