CREATE TABLE [dbo].[BOQPackagesDetails] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [PackageHeaderId] INT             NOT NULL,
    [StockItemId]     INT             NOT NULL,
    [NoOfItems]       INT             NOT NULL,
    [Average]         DECIMAL (18, 2) NOT NULL,
    [LocationId]      INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BOQPackagesDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

