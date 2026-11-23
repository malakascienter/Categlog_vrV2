CREATE TABLE [dbo].[tempStocKValChan] (
    [StockItemID]    INT              NOT NULL,
    [locationid]     INT              NOT NULL,
    [QuantityInHand] DECIMAL (18, 6)  NOT NULL,
    [InHand]         DECIMAL (18, 6)  NULL,
    [TXNHQYINHAND]   DECIMAL (18, 6)  NULL,
    [SMVAL]          DECIMAL (37, 12) NULL
);


GO

