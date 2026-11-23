CREATE TABLE [dbo].[TempStockItemRequestWiseLocations] (
    [Id]                 INT IDENTITY (1, 1) NOT NULL,
    [StockItemRequestId] INT NULL,
    [LocationId]         INT NULL,
    CONSTRAINT [PK__TempStoc__3214EC07D705946C] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

