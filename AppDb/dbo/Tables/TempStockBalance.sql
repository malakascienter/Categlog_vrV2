CREATE TABLE [dbo].[TempStockBalance] (
    [PropertyID] INT             NULL,
    [LocationID] INT             NULL,
    [ItemCode]   VARCHAR (50)    NULL,
    [CostPrice]  DECIMAL (18, 6) NULL,
    [QTY]        DECIMAL (18, 6) NULL,
    [ItemID]     INT             NULL,
    [UnitID]     VARCHAR (50)    NULL,
    [P]          INT             CONSTRAINT [DF__TempStockBala__P__42EF3DFB] DEFAULT ((0)) NOT NULL
);


GO

