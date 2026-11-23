
-- ==============================================================
-- Author:      Tharuka Sachintha
-- Create date: 2026-09-18
-- Description: Inline TVF returning the stock balance (in MasterUnitID)
--              for one StockItem at one Location, as of end of @Date.
--              Mirrors dbo.GetBalance's default (@OpeningBalance=0,@byValue=0)
--              branch, but written as an inline TVF so it can be used with
--              CROSS/OUTER APPLY and gets inlined into the query plan
--              (avoids the row-by-row scalar UDF execution problem).
-- ==============================================================
CREATE   FUNCTION [dbo].[TVF_RPT_ItemBalanceAsOfDate]
(
    @Date        DATE,
    @StockItemID INT,
    @LocationID  INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP (1)
        ISNULL(D.NewQuantity, 0) AS Balance
    FROM dbo.StockTransactionDetails AS D
    INNER JOIN dbo.StockTransactionHeaders AS H
        ON D.StockTransactionHeaderID = H.Id
    WHERE D.StockItemID = @StockItemID
      AND H.LocationID  = @LocationID
      AND H.TransactionDate < DATEADD(DAY, 1, @Date)
    ORDER BY H.TransactionDate DESC, D.Id DESC
)

GO

