-- =============================================
-- Author      : Tharuka Sachintha
-- Create date : 2026-06-10
-- Description :  Usage = Open Stock + GRN + Transfer In - Transfer Out - Issue Note - GRN Out - Closing Stock

--   SELECT * FROM dbo.FN_GetItemUsage_TVF('2018-08-10','2026-05-30', 3921, 1)

-- =============================================
CREATE   FUNCTION [dbo].[FN_GetItemUsage_TVF]
(
    @DateFrom    DATE,
    @DateTo      DATE,
    @StockItemID INT,
    @LocationID  INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        OpeningQty    = B.OpenQty,
        OpeningVal    = B.OpenVal,
        ClosingQty    = B.CloseQty,
        ClosingVal    = B.CloseVal,
        UsageQuantity = CAST(B.OpenQty + M.GRNq + M.TIq - M.TOq - M.INq - M.SRq - B.CloseQty AS DECIMAL(18,6)),
        UsageValue    = CAST(B.OpenVal + M.GRNv + M.TIv - M.TOv - M.INv - M.SRv - B.CloseVal AS DECIMAL(18,6))
    FROM
    (
        -- Movements within the window (single pass; one row even when no rows match).
        SELECT
            GRNq = ISNULL(SUM(CASE WHEN H.TransactionType = 'GR' THEN D.Quantity               END), 0),
            GRNv = ISNULL(SUM(CASE WHEN H.TransactionType = 'GR' THEN D.Quantity * D.UnitPrice END), 0),
            TIq  = ISNULL(SUM(CASE WHEN H.TransactionType = 'TI' THEN D.Quantity               END), 0),
            TIv  = ISNULL(SUM(CASE WHEN H.TransactionType = 'TI' THEN D.Quantity * D.UnitPrice END), 0),
            TOq  = ISNULL(SUM(CASE WHEN H.TransactionType = 'TO' THEN D.Quantity               END), 0),
            TOv  = ISNULL(SUM(CASE WHEN H.TransactionType = 'TO' THEN D.Quantity * D.UnitPrice END), 0),
            INq  = ISNULL(SUM(CASE WHEN H.TransactionType = 'IN' THEN D.Quantity               END), 0),
            INv  = ISNULL(SUM(CASE WHEN H.TransactionType = 'IN' THEN D.Quantity * D.UnitPrice END), 0),
            SRq  = ISNULL(SUM(CASE WHEN H.TransactionType = 'SR' THEN D.Quantity               END), 0),
            SRv  = ISNULL(SUM(CASE WHEN H.TransactionType = 'SR' THEN D.Quantity * D.UnitPrice END), 0)
        FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
        INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
                ON D.StockTransactionHeaderID = H.Id
        WHERE D.StockItemID = @StockItemID
          AND H.LocationID  = @LocationID
          AND H.TransactionDate BETWEEN @DateFrom AND @DateTo
    ) AS M
    CROSS APPLY
    (
        -- Opening balance: last balance strictly before @DateFrom.
        -- Closing balance: last balance on/before @DateTo.
        SELECT
            OpenQty  = ISNULL((SELECT TOP (1) D.NewQuantity
                               FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
                               INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
                                       ON D.StockTransactionHeaderID = H.Id
                               WHERE D.StockItemID = @StockItemID
                                 AND H.LocationID  = @LocationID
                                 AND H.TransactionDate < @DateFrom
                               ORDER BY H.TransactionDate DESC, H.CreatedDate DESC), 0),
            OpenVal  = ISNULL((SELECT TOP (1) D.NewQuantity * D.NewAveragePrice
                               FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
                               INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
                                       ON D.StockTransactionHeaderID = H.Id
                               WHERE D.StockItemID = @StockItemID
                                 AND H.LocationID  = @LocationID
                                 AND H.TransactionDate < @DateFrom
                               ORDER BY H.TransactionDate DESC, H.CreatedDate DESC), 0),
            CloseQty = ISNULL((SELECT TOP (1) D.NewQuantity
                               FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
                               INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
                                       ON D.StockTransactionHeaderID = H.Id
                               WHERE D.StockItemID = @StockItemID
                                 AND H.LocationID  = @LocationID
                                 AND H.TransactionDate < DATEADD(DAY, 1, @DateTo)
                               ORDER BY H.TransactionDate DESC, H.CreatedDate DESC), 0),
            CloseVal = ISNULL((SELECT TOP (1) D.NewQuantity * D.NewAveragePrice
                               FROM dbo.StockTransactionDetails AS D WITH (NOLOCK)
                               INNER JOIN dbo.StockTransactionHeaders AS H WITH (NOLOCK)
                                       ON D.StockTransactionHeaderID = H.Id
                               WHERE D.StockItemID = @StockItemID
                                 AND H.LocationID  = @LocationID
                                 AND H.TransactionDate < DATEADD(DAY, 1, @DateTo)
                               ORDER BY H.TransactionDate DESC, H.CreatedDate DESC), 0)
    ) AS B
)

GO

