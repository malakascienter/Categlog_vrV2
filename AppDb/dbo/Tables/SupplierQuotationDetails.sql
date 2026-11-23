CREATE TABLE [dbo].[SupplierQuotationDetails] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [QuotationHeaderId] INT             NULL,
    [ItemId]            INT             NULL,
    [UnitId]            INT             NULL,
    [UnitPrice]         DECIMAL (18, 6) NULL,
    [TaxGroupId]        INT             NULL,
    [PropertyId]        INT             NULL,
    CONSTRAINT [PK__Supplier__3214EC07F32A3D6E] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

