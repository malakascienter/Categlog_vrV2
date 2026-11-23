-- =============================================
-- Author:		Nivesh
-- Create date: 2025-08-01
-- Description:	Production consolidate report
-- =============================================
create PROCEDURE SP_RptProductionConsolidate 
	@FromDate DATE,
	@ToDate DATE,
	@location INT,
	@Category INT =-999,
	@Item INT = -999,
	@RequestLocation NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    CREATE TABLE #TempIDs(
    id INT)

    INSERT INTO #TempIDs
    SELECT id
    FROM OPENJSON(@RequestLocation)
    WITH (
        id INT
    );

    SELECT DISTINCT
		0 AS Approve,
        d.StockItemID,
        s.StockItemCode,
        s.Name AS StockItemName,
        d.RequestedDate,
        SD.QuantityInHand,
        rl.Name AS RequestLocation,
		dbo.FN_GetUnitConvertionRate(h.PropertyID,d.UnitID,sd.MasterUnitID) *  ISNULL(d.RequestedQTY, 0) AS RequestedQTY
		,h.ProductionLocationID
		,h.PropertyID
    FROM CommiRequestHeader h
    INNER JOIN CommiRequestDetails d ON d.HeaderID = h.ID
    INNER JOIN StockItemHeaders s ON d.StockItemID = s.Id
    INNER JOIN Locations rl ON h.RequestedLocationID = rl.Id
    INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = s.ID AND SD.LocationID = h.ProductionLocationID
    WHERE d.Status = 'A'
        AND d.RequestedDate BETWEEN @FromDate AND @ToDate
        AND (@Category = -999 OR s.CategoryID = @Category)
        AND (@Item = -999 OR s.Id = @Item)
        AND h.RequestedLocationID IN (
            SELECT id  
            FROM #TempIDs
        )
        AND h.ProductionLocationID =@location
    ORDER BY s.StockItemCode,d.RequestedDate
END

GO

