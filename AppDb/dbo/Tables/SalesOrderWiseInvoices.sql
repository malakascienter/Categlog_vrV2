CREATE TABLE [dbo].[SalesOrderWiseInvoices] (
    [Id]              INT      IDENTITY (1, 1) NOT NULL,
    [OrderID]         INT      NOT NULL,
    [InvoiceID]       INT      NOT NULL,
    [TransactionDate] DATETIME NOT NULL,
    CONSTRAINT [PK_dbo.SalesOrderWiseInvoices] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

