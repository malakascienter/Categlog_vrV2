CREATE TABLE [dbo].[RecipeHeaderLog] (
    [RecipeCode]         VARCHAR (50)    NOT NULL,
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Description]        VARCHAR (50)    DEFAULT (' ') NOT NULL,
    [Ord_Type]           CHAR (1)        DEFAULT ('B') NOT NULL,
    [LowerVariencePerc]  MONEY           DEFAULT ((0)) NOT NULL,
    [HigherVariencePerc] MONEY           DEFAULT ((0)) NOT NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [UpdateUserId]       INT             NULL,
    [UpdatedDateTime]    DATETIME        NULL,
    [PropertyId]         INT             NULL,
    [IsUpload]           BIT             NULL,
    [IsBanquetRecipe]    BIT             DEFAULT ((0)) NOT NULL,
    [AdditionalCost]     DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsPercentage]       BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RecipeHeaderLog] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO

