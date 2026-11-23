 
CREATE PROCEDURE [dbo].[SP_RPT_CurrentInventory](@CompanyId INT, @LocationId INT,@CategoryId INT)
AS
BEGIN
	SELECT DISTINCT C.Name AS Category, SH.StockItemCode, SH.Name AS ItemName,SD.QuantityInHand, SD.ReOrderLevel,SD.ReOrderQuantity,L.Name AS Location
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Categories C ON C.Id = SH.CategoryID
	INNER JOIN Locations L ON L.Id = SD.LocationID
	WHERE SH.CompanyId = @CompanyId 
	AND SD.LocationID = CASE WHEN @LocationId = -999 THEN SD.LocationID ELSE @LocationId END
	AND SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID ELSE @CategoryId END
END

GO

