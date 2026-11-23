

CREATE FUNCTION  [dbo].[FN_GetTopMasterUnit] (@HeaderId INT) 

RETURNS VARCHAR(500)
AS
BEGIN
	DECLARE @UintName VARCHAR(500)

	SELECT TOP(1) @UintName = U.Name
	FROM dbo.StockItemDetails AS SH
	INNER JOIN UNits U ON U.Id = SH.MasterUnitID 
	INNER JOIN LOCATIONS LO ON LO.ID = SH.LocationID
	WHERE StockItemHeaderID=@HeaderId AND LO.IsMainStore=1

	RETURN @UintName

	 

END

GO

