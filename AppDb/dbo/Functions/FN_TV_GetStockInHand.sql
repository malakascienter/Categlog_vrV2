-- =============================================
-- Author:		Tharuka sachintha
-- Create date: 2026-05-25
-- Description: get all item stocks in hand bby passing location 
-- =============================================
CREATE   FUNCTION [dbo].[FN_TV_GetStockInHand]
(
    @PropertyId     INT,
    @LocationID     INT,
    @StockItemId    INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT ISNULL(SD.QuantityInHand, 0) AS QuantityInHand
    FROM dbo.StockItemDetails SD
    WHERE SD.LocationID      = @LocationID
      AND SD.StockItemHeaderID = @StockItemId
);

GO

