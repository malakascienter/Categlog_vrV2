CREATE PROCEDURE SelectProductionItem
	@LocationId INT = -999
AS
BEGIN
	SELECT DISTINCT H.Id, H.Name AS text, D.MasterUnitID AS UnitId, H.IsExpiryDateApplicable
	FROM StockItemHeaders H
	INNER JOIN StockItemDetails D ON D.StockItemHeaderID = H.Id
	WHERE D.LocationID = CASE WHEN @LocationId = -999 THEN D.LocationID  ELSE @LocationId END
	AND h.IsProductionItem = 1
END

GO

