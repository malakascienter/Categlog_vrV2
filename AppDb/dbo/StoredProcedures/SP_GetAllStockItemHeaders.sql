CREATE PROCEDURE [dbo].[SP_GetAllStockItemHeaders] 

@PropertyID int,
@LocationID int

AS BEGIN

SELECT DISTINCT ( SH.Id ) ,SH.Name AS Name ,SH.StockItemCode AS Code ,SD.MasterUnitID,U.Name AS UnitName,
SD.QuantityInHand, L.Name Location,SD.AveragePrice 
FROM stockitemheaders SH
INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID=SH.Id
INNER JOIN Units U ON U.Id=SD.MasterUnitID
LEFT JOIN Locations L ON L.Id = SD.LocationID
WHERE SH.CompanyId = CASE WHEN @PropertyID = -999 THEN SH.CompanyId ELSE @PropertyID END
AND SD.LocationID=CASE WHEN @LocationID = -999 THEN SD.LocationID ELSE @LocationID END

END

GO

