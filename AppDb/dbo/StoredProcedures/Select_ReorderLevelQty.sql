-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-05-07
-- Description:	Re order level Qty Check

-- [dbo].[Select_ReorderLevelQty] 1,-999

-- =============================================
CREATE PROCEDURE [dbo].[Select_ReorderLevelQty]
	@PropertyID INT,
	@LocationID INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT LO.Name LocationName,SH.StockItemCode,SH.Name ItemName,U.Name UnitName,SD.QuantityInHand,SD.ReOrderLevel,sd.ReOrderQuantity
	,SH.Id StockItemID,SD.LocationID,CASE WHEN  SD.QuantityInHand < SD.ReOrderLevel THEN 1 WHEN SD.QuantityInHand = SD.ReOrderLevel THEN 2 END AS Level
	,CO.Name CompanyName
	FROM StockItemHeaders SH
	INNER JOIN StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Locations LO ON LO.Id = SD.LocationID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	INNER JOIN Companies CO ON CO.CompanyID = SH.CompanyId
	WHERE SH.CompanyId = @PropertyID AND SD.ReOrderLevel>0
	AND SD.LocationID = CASE WHEN @LocationID = -999 THEN SD.LocationID ELSE @LocationID END
	AND SD.QuantityInHand <= SD.ReOrderLevel
	AND SD.IsActive=1
	ORDER BY SD.QuantityInHand ASC

 
END

GO

