CREATE  FUNCTION dbo.Get_LastGRNDate_ForPR
(
    @RequestHeaderID INT,
    @StockItemID INT
)
RETURNS DATE
AS
BEGIN
    DECLARE @PoHeaderID INT,
            @LastGRNDate DATE;

    -- Step 1: Get latest PO header for the given PR and stock item
    SELECT TOP 1 @PoHeaderID = PoHeaderID
    FROM PoWisePRs
    WHERE RequestHeaderID = @RequestHeaderID
      AND StockItemID = @StockItemID
    ORDER BY CreatedDate DESC;

    -- Step 2: Get latest GRN transaction date
    SELECT TOP 1 @LastGRNDate = SH.TransactionDate
    FROM StockTransactionHeaders SH
    INNER JOIN StockTransactionDetails SD
        ON SH.ID = SD.StockTransactionHeaderID
    WHERE SD.StockItemID = @StockItemID
      AND SH.ReferenceID = @PoHeaderID
      AND SH.TransactionType = 'GR'
    ORDER BY SH.TransactionDate DESC;

    RETURN @LastGRNDate;
END;

GO

