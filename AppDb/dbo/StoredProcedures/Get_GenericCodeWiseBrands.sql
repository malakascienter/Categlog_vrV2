
--[dbo].[Get_GenericCodeWiseBrands] 'CH001',1235,6,1

CREATE PROCEDURE [dbo].[Get_GenericCodeWiseBrands] (@GenericCode VARCHAR(300) , @ItemId INT , @locationID INT, @CompanyId INT)

AS
BEGIN

	SELECT @ItemId = Id
	FROM StockItemHeaders
	WHERE StockItemCode = @GenericCode
	AND CompanyId=@CompanyId

SELECT DISTINCT SH.Id AS ItemId, SH.Name AS ItemName, SH.StockItemCode AS ItemCode, U.Id AS UnitId, U.Name AS UnitCode,U.Code AS UnitCode2,
SD.QuantityInHand AS QtyInHand,dbo.FN_GetLastAveragePrice(sd.locationid, sh.id)    AS UnitPrice , dbo.FN_GetUnitConvertionRate( SH.CompanyId, G.MasterUnitID, SD.MasterUnitID) Convertion,SD.LocationID
FROM  dbo.StockItemHeaders SH
INNER JOIN dbo.StockItemDetails SD ON SH.Id = SD.StockItemHeaderID
LEFT JOIN dbo.Units U ON U.Id = SD.MasterUnitID
INNER JOIN StockItemDetails G ON G.StockItemId = @ItemId and SD.LocationID = G.LocationID
--LEFT JOIN dbo.RequestDetails rd ON rd.StockItemID = SH.Id
WHERE Sh.GenericItemCode = @GenericCode   AND SD.LocationID=@locationID

END

GO

