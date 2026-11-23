CREATE TABLE [dbo].[TempStockItmes] (
    [StockItemCode]     NVARCHAR (255) NULL,
    [PLUCode]           NVARCHAR (255) NULL,
    [Name]              NVARCHAR (255) NULL,
    [Categories]        NVARCHAR (255) NULL,
    [SubCategories]     NVARCHAR (255) NULL,
    [SubCat02]          NVARCHAR (255) NULL,
    [Site]              NVARCHAR (255) NULL,
    [Size]              NVARCHAR (255) NULL,
    [Location]          FLOAT (53)     NULL,
    [CategoryID]        INT            NULL,
    [SubCategory]       INT            NULL,
    [SubCategory2]      INT            NULL,
    [UnitID]            INT            NULL,
    [PropertyID]        INT            CONSTRAINT [DF__TempStock__Prope__786E9B11] DEFAULT ((2)) NOT NULL,
    [StockItemHeaderID] INT            NULL
);


GO

