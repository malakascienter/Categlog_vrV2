CREATE PROCEDURE [dbo].[SP_GetCategoryWiseStockItems] 
    @CategoryId INT, 
    @LocationId INT, 
    @PropertyId INT
AS
BEGIN
    SELECT sth.id AS Id, sth.name AS Name
    FROM stockitemheaders sth 
    INNER JOIN stockitemdetails sd ON sth.id = sd.stockitemheaderid
    WHERE categoryID = CASE WHEN @CategoryId = -999 THEN sth.CategoryID ELSE @CategoryId END 
    AND sd.LocationID = CASE WHEN @LocationId = -999 THEN sd.LocationID ELSE @LocationId END 
    AND sth.CompanyId = CASE WHEN @PropertyId = -999 THEN sth.CompanyId ELSE @PropertyId END
    ORDER BY sth.name ASC; -- Order by Name column in ascending order
END

GO

