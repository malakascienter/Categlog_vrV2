CREATE TABLE [dbo].[BillWiseTaxDetails] (
    [Id]        INT             IDENTITY (1, 1) NOT NULL,
    [BillID]    INT             NOT NULL,
    [TaxTypeId] INT             NOT NULL,
    [TaxPer]    DECIMAL (18, 2) NOT NULL,
    [TaxVal]    DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.BillWiseTaxDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

