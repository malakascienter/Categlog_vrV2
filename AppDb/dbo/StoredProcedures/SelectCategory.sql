CREATE PROCEDURE [dbo].[SelectCategory]
AS
BEGIN
	SELECT DISTINCT c.Id,c.Code,c.Name AS CategoryName
	FROM Categories c
	INNER JOIN StockItemHeaders s ON c.Id = s.CategoryId
END

GO

