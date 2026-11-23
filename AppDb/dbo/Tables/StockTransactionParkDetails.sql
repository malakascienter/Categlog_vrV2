CREATE TABLE [dbo].[StockTransactionParkDetails] (
    [Idx]             BIGINT          IDENTITY (1, 1) NOT NULL,
    [LocationID]      INT             NULL,
    [StockItemID]     BIGINT          NULL,
    [TransactionDate] DATE            NULL,
    [CurQuantity]     DECIMAL (18, 6) NULL,
    [TxnQuantity]     DECIMAL (18, 6) NULL,
    [ParkQuantity]    DECIMAL (18, 6) NULL
);


GO

