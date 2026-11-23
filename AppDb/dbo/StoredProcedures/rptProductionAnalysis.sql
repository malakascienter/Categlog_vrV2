-- rptProductionAnalysis 'C','2024-08-31','2024-09-30'
CREATE PROCEDURE rptProductionAnalysis
	@Status VARCHAR(4),
	@FromDate DATE,
	@ToDate DATE
AS
BEGIN

	SELECT s.Name, l.Name Location,
	CASE WHEN cd.Status = 'A' THEN cd.ApprovedQTY ELSE cd.RequestedQTY END AS Qty
	FROM Locations l
	LEFT JOIN CommiRequestHeader ch ON ch.RequestedLocationID = l.Id
	LEFT JOIN CommiRequestDetails cd ON cd.HeaderID = ch.ID
	LEFT JOIN StockItemHeaders s on s.Id = cd.StockItemID
	WHERE (cd.RequestedDate BETWEEN @FromDate AND @ToDate OR cd.RequestedDate IS NULL)
	AND (ch.Status = CASE WHEN @Status = 'ALL' THEN ch.Status ELSE @Status END OR ch.Status IS NULL)
	ORDER BY s.Name DESC


END

GO

