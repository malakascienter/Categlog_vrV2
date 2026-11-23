CREATE TABLE [dbo].[POwiseTaxes] (
    [POTaxesID]   INT             IDENTITY (1, 1) NOT NULL,
    [PODetailID]  INT             NOT NULL,
    [StockItemID] INT             NOT NULL,
    [TaxTypeID]   INT             NOT NULL,
    [TaxAmount]   DECIMAL (18, 6) NOT NULL,
    CONSTRAINT [PK_dbo.POwiseTaxes] PRIMARY KEY CLUSTERED ([POTaxesID] ASC)
);


GO

