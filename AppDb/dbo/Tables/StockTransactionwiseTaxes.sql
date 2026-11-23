CREATE TABLE [dbo].[StockTransactionwiseTaxes] (
    [StockTransactionwiseTaxesID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [StockTransactionDetailID]    BIGINT          NOT NULL,
    [StockItemID]                 INT             NOT NULL,
    [TaxTypeID]                   INT             NOT NULL,
    [TaxAmount]                   DECIMAL (18, 8) NOT NULL,
    CONSTRAINT [PK_dbo.StockTransactionwiseTaxes] PRIMARY KEY CLUSTERED ([StockTransactionwiseTaxesID] ASC)
);


GO

