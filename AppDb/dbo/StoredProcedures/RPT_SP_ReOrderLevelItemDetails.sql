-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-07-27
-- Description:	get details of items including reorder level
-- [dbo].[RPT_SP_ReOrderLevelItemDetails] -999, -999, 1
-- =============================================
CREATE   PROCEDURE [dbo].[RPT_SP_ReOrderLevelItemDetails] 
	@LocationID INT,
	@CategoryId INT,
	@PropertyID INT
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT SH.Name AS ItemName, SH.StockItemCode, SD.AveragePrice, SD.QuantityInHand, SD.ItemAge, L.Name AS LocationName, C.Name AS CategoryName, U.Name AS MasterUnit,
	SD.ReOrderLevel, SD.ReOrderQuantity
	FROM StockItemDetails SD 
	INNER JOIN StockItemHeaders SH ON SH.Id = SD.StockItemHeaderID
	INNER JOIN Units U ON SD.MasterUnitID = U.Id
	INNER JOIN Categories C ON SH.CategoryID = C.Id
	INNER JOIN Locations L ON SD.LocationID = L.Id
	WHERE SD.LocationId = CASE WHEN @LocationID = -999 THEN SD.LocationId  ELSE @LocationID END
	AND SH.CategoryID = CASE WHEN @CategoryId = -999 THEN SH.CategoryID  ELSE @CategoryId END
	AND SD.PropertyID = @PropertyID
END

GO

