CREATE TABLE [dbo].[RecipeHeader] (
    [RecipeCode]         VARCHAR (50)    NOT NULL,
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Description]        VARCHAR (50)    CONSTRAINT [DF_RecipeHeader_Description] DEFAULT (' ') NOT NULL,
    [Ord_Type]           CHAR (1)        CONSTRAINT [DF_RecipeHeader_Ord_Type_1] DEFAULT ('B') NOT NULL,
    [LowerVariencePerc]  MONEY           CONSTRAINT [DF__RecipeHea__Lower__767105AF] DEFAULT ((0)) NOT NULL,
    [HigherVariencePerc] MONEY           CONSTRAINT [DF__RecipeHea__Highe__776529E8] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [UpdateUserId]       INT             NULL,
    [UpdatedDateTime]    DATETIME        NULL,
    [PropertyId]         INT             NULL,
    [IsUpload]           BIT             NULL,
    [IsBanquetRecipe]    BIT             DEFAULT ((0)) NOT NULL,
    [AdditionalCost]     DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [IsPercentage]       BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_RecipeHeader] PRIMARY KEY NONCLUSTERED ([RecipeCode] ASC, [Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IDX_RecipeHeader_RecipeCode_PropertyId]
    ON [dbo].[RecipeHeader]([RecipeCode] ASC, [PropertyId] ASC);


GO

