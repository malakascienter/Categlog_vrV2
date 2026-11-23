-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-02-20
-- Description:	get data for stock transaction report
-- EXEC SP_SelectStockTransaction '2026-02-23', '2026-02-23', 1,7
-- =============================================
CREATE PROCEDURE [dbo].[RPT_TransferSummaryReport]
	@FromDate VARCHAR(100),
	@ToDate VARCHAR(100),
	@FromLocationID INT,
	@ToLocationID INT
AS
BEGIN
	SET NOCOUNT ON;

    SELECT 
        SIH.StockItemCode AS ItemCode,
        SIH.Name AS ItemName, 
        SUM(STD.Quantity) AS Quantity,
        UN.Name AS Unit,
        LO1.Name AS LocationName,
        LO2.Name AS TransferLocation
    FROM StockTransactionHeaders STH
    INNER JOIN StockTransactionDetails STD ON STD.StockTransactionHeaderID = STH.ID
    INNER JOIN StockItemHeaders SIH ON SIH.ID = STD.StockItemID
    INNER JOIN Units UN ON UN.ID = STD.TxnUnitID
    INNER JOIN StockItemDetails SD ON SD.StockItemHeaderID = SIH.Id
    INNER JOIN Locations LO1 ON LO1.Id = STH.LocationID
    INNER JOIN Locations LO2 ON LO2.Id = STH.TransferLocationID
    WHERE 
        STH.TransactionType = 'TO' 
        AND STH.TransactionDate BETWEEN @FromDate AND @ToDate 
        AND STH.LocationID = @FromLocationID 
        AND STH.TransferLocationID = @ToLocationID
    GROUP BY 
        SIH.StockItemCode,
        SIH.Name,
        UN.Name,
        LO1.Name,
        LO2.Name,
        STD.StockTransactionHeaderID

END

GO

