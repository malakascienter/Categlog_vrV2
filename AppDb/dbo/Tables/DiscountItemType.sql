CREATE TABLE [dbo].[DiscountItemType] (
    [Code]         VARCHAR (2) DEFAULT ('') NOT NULL,
    [ItemTypeCode] VARCHAR (2) DEFAULT ('') NOT NULL,
    [SysDate]      DATETIME    DEFAULT (getdate()) NOT NULL,
    [PropertyId]   INT         DEFAULT ((0)) NOT NULL
);


GO

