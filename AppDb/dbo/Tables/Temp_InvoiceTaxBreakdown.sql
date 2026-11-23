CREATE TABLE [dbo].[Temp_InvoiceTaxBreakdown] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [InvoiceDetailID] INT             NOT NULL,
    [InvoiceHeaderID] INT             NOT NULL,
    [ItemID]          INT             NOT NULL,
    [TaxID]           INT             NOT NULL,
    [TaxRate]         DECIMAL (18, 2) NOT NULL,
    [TaxValue]        DECIMAL (18, 2) NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.Temp_InvoiceTaxBreakdown] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

