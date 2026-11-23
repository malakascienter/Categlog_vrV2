CREATE TABLE [dbo].[PriceChangeLogs] (
    [Id]                INT      IDENTITY (1, 1) NOT NULL,
    [StockItemHeaderId] INT      NOT NULL,
    [LocationId]        INT      NOT NULL,
    [NewPrice]          MONEY    NOT NULL,
    [OldPrice]          MONEY    NOT NULL,
    [EffectedDate]      DATETIME NOT NULL,
    [CreateUser]        INT      NOT NULL,
    [CreatedDate]       DATETIME NOT NULL,
    [ModifiedUser]      INT      NOT NULL,
    [ModifiedDate]      DATETIME NOT NULL,
    CONSTRAINT [PK_dbo.PriceChangeLogs] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

