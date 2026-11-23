-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-09-11
-- Description:	Stock Variance Report
-- [dbo].[SP_StockVarianceReport] 3,1,-999,-999,'2026-08-30','2026-09-13'

-- =============================================
CREATE PROCEDURE [dbo].[SP_StockVarianceReport]
	@LocationID INT,
	@PropertyID INT,
	@CategoryID INT,
	@StockItemID INT,
	@FromDate DATE,
	@ToDate DATE
AS
BEGIN
	SET NOCOUNT ON;
	SELECT	LO.Name AS LocationName,
	CAT.Name AS CategoryName,
	SIH.StockItemCode,
	SIH.Name AS StockItemName,
	U.Name AS UnitName,
	SUM(CASE WHEN SD.TxnType = 'M' THEN -1 * SD.Quantity
				ELSE SD.Quantity END) AS Qty,
	SUM(CASE WHEN SD.TxnType = 'M' THEN (-1 * SD.Quantity) * SD.UnitPrice
				ELSE SD.Quantity * SD.UnitPrice END) AS VarianceValue
	FROM StockTransactionHeaders SH
	INNER JOIN StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	INNER JOIN StockItemHeaders SIH ON SIH.Id = SD.StockItemID
	INNER JOIN Locations LO ON LO.Id = SH.LocationID
	INNER JOIN Units U ON U.Id = SD.MasterUnitID
	LEFT JOIN Categories CAT ON CAT.Id = SIH.CategoryID
	WHERE SH.PropertyID = @PropertyID
	AND SH.LocationID = @LocationID
	AND SH.TransactionDate BETWEEN @FromDate AND @ToDate
	AND SH.TransactionType = 'AA'
	AND (@CategoryID = -999 OR SIH.CategoryID = @CategoryID)
	AND (@StockItemID = -999 OR SD.StockItemID = @StockItemID)
	GROUP BY LO.Name, CAT.Name, SIH.StockItemCode, SIH.Name, U.Name
	ORDER BY SIH.StockItemCode

END

GO

