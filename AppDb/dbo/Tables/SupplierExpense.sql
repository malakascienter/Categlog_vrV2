CREATE TABLE [dbo].[SupplierExpense] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [SupplierId]      INT             DEFAULT ((0)) NOT NULL,
    [SupplierName]    NVARCHAR (255)  DEFAULT ('') NOT NULL,
    [PropertyId]      INT             DEFAULT ((0)) NOT NULL,
    [TxnDate]         DATETIME        DEFAULT (getdate()) NOT NULL,
    [Amount]          DECIMAL (18, 2) DEFAULT ((0.00)) NOT NULL,
    [Remark]          NVARCHAR (MAX)  DEFAULT ('') NOT NULL,
    [CreatedUserId]   INT             DEFAULT ((0)) NOT NULL,
    [CreatedDateTime] DATETIME        DEFAULT (getdate()) NOT NULL,
    [EditedUserId]    INT             NULL,
    [EditedDateTime]  DATETIME        NULL,
    [InvoiceNo]       VARCHAR (50)    DEFAULT ('') NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

