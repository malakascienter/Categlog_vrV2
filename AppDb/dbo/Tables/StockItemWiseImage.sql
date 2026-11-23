CREATE TABLE [dbo].[StockItemWiseImage] (
    [Id]          INT           IDENTITY (1, 1) NOT NULL,
    [StockItemId] BIGINT        NOT NULL,
    [ItemImage]   IMAGE         NULL,
    [PropertyId]  INT           DEFAULT ((0)) NOT NULL,
    [ImageName]   VARCHAR (100) DEFAULT ('no-image.png') NOT NULL
);


GO

