CREATE TABLE [dbo].[ProjectWisePriceLogDetails] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [HeaderId]        INT             NOT NULL,
    [ProjectID]       INT             NOT NULL,
    [SupplierID]      INT             NOT NULL,
    [StockItemID]     INT             NOT NULL,
    [Price]           DECIMAL (18, 2) NOT NULL,
    [DiscountValue]   DECIMAL (18, 2) NULL,
    [NetPrice]        DECIMAL (18, 2) NULL,
    [IPAddress]       VARCHAR (50)    NULL,
    [CreatedUserID]   INT             NULL,
    [LastModUserID]   INT             NULL,
    [CreatedDate]     DATETIME        NULL,
    [LastModDate]     DATETIME        NULL,
    [DefaultSupplier] INT             NULL,
    CONSTRAINT [PK_ProjectWisePriceLogDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

