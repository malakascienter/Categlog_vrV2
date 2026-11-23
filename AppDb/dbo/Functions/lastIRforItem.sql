-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-04-22
-- Description:	return last record of Issue request item date and doc nomber 
-- =============================================

-- SELECT * FROM dbo.lastIRforItem(20, 66,1);


CREATE   FUNCTION [dbo].[lastIRforItem]
(
    @headerID INT,
    @ItemID   INT,
    @locationID INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 1
        STH.TransactionDate,
        STH.DocumentNo
    FROM  StockTransactionHeaders STH
    INNER JOIN StockTransactionDetails STD
           ON  STH.ID = std.StockTransactionHeaderID
    WHERE  STH.TransactionType = 'IN'
      AND  STH.ReferenceID     = @headerID
      AND  STD.StockItemID     = @ItemID
      AND  STH.LocationID = @locationID
    ORDER BY sth.TransactionDate DESC
)

GO

