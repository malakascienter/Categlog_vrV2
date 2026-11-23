CREATE TABLE [dbo].[xxx_StockTransactionHeaders] (
    [id]                INT            NOT NULL,
    [TransactionDate]   DATETIME       NOT NULL,
    [ReferenceDocument] VARCHAR (1)    NOT NULL,
    [DocumentTitle]     NVARCHAR (MAX) NULL,
    [DocumentNo]        NVARCHAR (20)  NULL,
    [CompanyName]       NVARCHAR (100) NULL,
    [SupplierName]      NVARCHAR (100) NULL,
    [suppliercode]      NVARCHAR (10)  NULL,
    [LocationName]      NVARCHAR (MAX) NULL,
    [SupplyCurrentcy]   NVARCHAR (MAX) NULL,
    [Isprinted]         INT            NOT NULL,
    [printeddate]       DATETIME       NOT NULL,
    [printedtime]       DATETIME       NOT NULL,
    [usename]           VARCHAR (1)    NOT NULL
);


GO

