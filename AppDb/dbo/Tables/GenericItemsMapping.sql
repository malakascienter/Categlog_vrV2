CREATE TABLE [dbo].[GenericItemsMapping] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [GenericItemId] INT           NULL,
    [StockItemId]   VARCHAR (255) NULL,
    CONSTRAINT [PK__GenericI__3214EC07038CBA0D] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

