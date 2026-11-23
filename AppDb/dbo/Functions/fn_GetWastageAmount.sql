-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-06-08
-- Description:	Return Wastage amount 
-- =============================================
CREATE FUNCTION dbo.fn_GetWastageAmount
(
    @StockItemID INT,
    @TransactionDate DATE,
    @LocationID INT
)
RETURNS TABLE
AS
RETURN
(
    WITH WastageCTE AS
    (
        SELECT	TOP 1
            TRY_CAST(Remarks AS DECIMAL(10,2)) AS WastagePercentage
        FROM StockItemWiseAttributes
        WHERE StockItemAttributeID = 24
            AND Remarks <> ''
            AND StockItemHeaderID = @StockItemID
    ),
    FromDateCTE AS
    (
        SELECT TOP 1 SH.TransactionDate AS FromDate
        FROM StockTransactionHeaders SH
        INNER JOIN StockTransactionDetails SD 
            ON SH.ID = SD.StockTransactionHeaderID
        WHERE SH.TransactionDate <> @TransactionDate
            AND SD.StockItemID = @StockItemID
            AND SH.LocationID = @LocationID
            AND SH.TransactionType = 'AA'
        ORDER BY SH.TransactionDate DESC
    ),
    QtyCTE AS
    (
        SELECT 
            ISNULL(SUM(SD.Quantity), 0) AS Qty
        FROM StockTransactionHeaders SH
        INNER JOIN StockTransactionDetails SD 
            ON SH.ID = SD.StockTransactionHeaderID
        CROSS JOIN FromDateCTE FD
        WHERE SH.LocationID = @LocationID
            AND SH.TransactionType = 'PI'
            AND SD.StockItemID = @StockItemID
            AND SH.TransactionDate BETWEEN FD.FromDate AND @TransactionDate
    )
    SELECT 
        @StockItemID AS StockItemID,
        ISNULL(Q.Qty * W.WastagePercentage / 100, 0) AS WastageAmount
		,CONCAT(ISNULL(W.WastagePercentage,0),+'%') WastagePercentage
    FROM QtyCTE Q
    CROSS JOIN WastageCTE W
);

GO

