CREATE TABLE [dbo].[CustomerSuppliedStockHeaders] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [TxnNumber]       NVARCHAR (MAX)  NULL,
    [TxnDate]         DATETIME        NOT NULL,
    [ProjectID]       INT             NOT NULL,
    [CustID]          INT             NOT NULL,
    [BOQID]           INT             NOT NULL,
    [deptID]          INT             NOT NULL,
    [TotalValue]      DECIMAL (18, 2) NOT NULL,
    [Status]          NVARCHAR (MAX)  NULL,
    [Completed]       BIT             NOT NULL,
    [Billed]          BIT             NOT NULL,
    [BillNumber]      NVARCHAR (MAX)  NULL,
    [invoiced]        BIT             NOT NULL,
    [invoiceNo]       NVARCHAR (MAX)  NULL,
    [PropertyID]      INT             DEFAULT ((0)) NOT NULL,
    [LocationID]      INT             DEFAULT ((0)) NOT NULL,
    [TransactionType] NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.CustomerSuppliedStockHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

