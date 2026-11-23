CREATE TABLE [dbo].[ProjectWiseSupplierPrices] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [ProjectID]       INT             NOT NULL,
    [SupplierID]      INT             NOT NULL,
    [StockItemID]     INT             NOT NULL,
    [Price]           DECIMAL (18, 2) NOT NULL,
    [DiscountValue]   DECIMAL (18, 2) NOT NULL,
    [NetPrice]        DECIMAL (18, 2) NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    [DefaultSupplier] INT             NULL,
    [Approved]        BIT             NULL,
    [Status]          CHAR (2)        NULL,
    [TransactionId]   INT             NULL,
    CONSTRAINT [PK_dbo.ProjectWiseSupplierPrices] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

