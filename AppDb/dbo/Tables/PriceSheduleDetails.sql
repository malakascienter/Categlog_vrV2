CREATE TABLE [dbo].[PriceSheduleDetails] (
    [Id]                     INT        IDENTITY (1, 1) NOT NULL,
    [SheduleHeaderD]         INT        NOT NULL,
    [StockItemID]            INT        NOT NULL,
    [MasterUnit]             INT        NOT NULL,
    [NewPrice]               FLOAT (53) NOT NULL,
    [PriceSheduleHeaders_Id] INT        NULL,
    CONSTRAINT [PK_dbo.PriceSheduleDetails] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_dbo.PriceSheduleDetails_dbo.PriceSheduleHeaders_PriceSheduleHeaders_Id] FOREIGN KEY ([PriceSheduleHeaders_Id]) REFERENCES [dbo].[PriceSheduleHeaders] ([Id])
);


GO

CREATE NONCLUSTERED INDEX [IX_PriceSheduleHeaders_Id]
    ON [dbo].[PriceSheduleDetails]([PriceSheduleHeaders_Id] ASC);


GO

