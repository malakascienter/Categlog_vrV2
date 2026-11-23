CREATE TABLE [dbo].[DiscountBinNumbers] (
    [Code]                 VARCHAR (10) DEFAULT ('') NOT NULL,
    [BinNumber]            VARCHAR (10) DEFAULT ('') NOT NULL,
    [PropertyId]           INT          DEFAULT ((0)) NOT NULL,
    [CreatedUserId]        INT          DEFAULT ((0)) NOT NULL,
    [LastModifiedUserID]   INT          DEFAULT ((0)) NOT NULL,
    [CreatedDateTime]      DATETIME     DEFAULT (getdate()) NOT NULL,
    [LastModifiedDateTime] DATETIME     DEFAULT (getdate()) NOT NULL
);


GO

