CREATE TABLE [dbo].[RecipeDetails] (
    [RecipeCode]      VARCHAR (6) NOT NULL,
    [StockItemCode]   INT         NOT NULL,
    [Seq]             INT         CONSTRAINT [DF_RecipeDetails_Seq] DEFAULT ((0)) NULL,
    [Unit]            CHAR (3)    NOT NULL,
    [Qty]             MONEY       CONSTRAINT [DF_RecipeDetails_Qty] DEFAULT ((0)) NOT NULL,
    [Cost]            MONEY       CONSTRAINT [DF_RecipeDetails_Cost] DEFAULT ((0)) NOT NULL,
    [Yeild]           MONEY       CONSTRAINT [DF_RecipeDetails_Yeild] DEFAULT ((0)) NOT NULL,
    [Ord_Type]        CHAR (1)    CONSTRAINT [DF_RecipeDetails_Ord_Type] DEFAULT ('B') NOT NULL,
    [Loc]             VARCHAR (3) CONSTRAINT [DF_RecipeDetails_Loc] DEFAULT (' ') NOT NULL,
    [isMainItem]      BIT         CONSTRAINT [DF__RecipeDet__isMai__1550F9CF] DEFAULT ((0)) NOT NULL,
    [Type]            CHAR (1)    CONSTRAINT [DF_RecipeDetails_Type] DEFAULT ('') NOT NULL,
    [CreatedUserId]   INT         NULL,
    [CreatedDateTime] DATETIME    NULL,
    [UpdateUserId]    INT         NULL,
    [UpdatedDateTime] DATETIME    NULL,
    [IsUpload]        INT         NULL,
    [PropertyId]      INT         NULL,
    [Id]              BIGINT      IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_RecipeDetails] PRIMARY KEY NONCLUSTERED ([RecipeCode] ASC, [StockItemCode] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IDX_RecipeDetails_RecipeCode_PropertyId]
    ON [dbo].[RecipeDetails]([RecipeCode] ASC, [PropertyId] ASC)
    INCLUDE([StockItemCode]);


GO

