CREATE PROCEDURE [dbo].[SP_GetUnitCoversionByLoc] 
	@stockItemHeaderID INT,
	@locationID INT
AS
BEGIN

SELECT TOP 1 SD.MasterUnitID,U.Name  FROM dbo.StockItemHeaders SH INNER jOIN
dbo.StockItemDetails SD on SH.id= SD.StockItemHeaderID INNER JOIN 
dbo.Units U ON U.id=SD.MasterUnitID WHERE SH.Id=@stockItemHeaderID AND SD.LocationID=@locationID


END

GO

