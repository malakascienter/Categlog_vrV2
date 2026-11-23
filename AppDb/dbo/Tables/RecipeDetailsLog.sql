CREATE TABLE [dbo].[RecipeDetailsLog] (
    [Id]              INT         IDENTITY (1, 1) NOT NULL,
    [RecipeCode]      VARCHAR (6) NOT NULL,
    [StockItemCode]   INT         NOT NULL,
    [Seq]             INT         DEFAULT ((0)) NULL,
    [Unit]            CHAR (3)    NOT NULL,
    [Qty]             MONEY       DEFAULT ((0)) NOT NULL,
    [Cost]            MONEY       DEFAULT ((0)) NOT NULL,
    [Yeild]           MONEY       DEFAULT ((0)) NOT NULL,
    [Ord_Type]        CHAR (1)    DEFAULT ('B') NOT NULL,
    [Loc]             VARCHAR (3) DEFAULT (' ') NOT NULL,
    [isMainItem]      BIT         DEFAULT ((0)) NOT NULL,
    [Type]            CHAR (1)    DEFAULT ('') NOT NULL,
    [CreatedUserId]   INT         NULL,
    [CreatedDateTime] DATETIME    NULL,
    [UpdateUserId]    INT         NULL,
    [UpdatedDateTime] DATETIME    NULL,
    [IsUpload]        INT         NULL,
    [PropertyId]      INT         NULL,
    CONSTRAINT [PK_RecipeDetailsLog] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO

