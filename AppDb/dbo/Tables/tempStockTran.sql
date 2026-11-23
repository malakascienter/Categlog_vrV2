CREATE TABLE [dbo].[tempStockTran] (
    [ID]                       INT      IDENTITY (1, 1) NOT NULL,
    [logate]                   DATETIME DEFAULT (getdate()) NOT NULL,
    [XmlDATA]                  XML      NULL,
    [StockTransactionHeaderID] INT      NULL
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [IX_tempStockTran_ID]
    ON [dbo].[tempStockTran]([ID] ASC);


GO

