CREATE TABLE [dbo].[CustomerSuppliedStockDetails] (
    [Id]         INT             IDENTITY (1, 1) NOT NULL,
    [HeaderID]   INT             NOT NULL,
    [ItemID]     INT             NOT NULL,
    [unitID]     INT             NOT NULL,
    [UnitPrice]  DECIMAL (18, 2) NOT NULL,
    [Qunatity]   DECIMAL (18, 2) NOT NULL,
    [TotalValue] DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_dbo.CustomerSuppliedStockDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

