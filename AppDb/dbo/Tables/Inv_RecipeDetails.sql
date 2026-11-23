CREATE TABLE [dbo].[Inv_RecipeDetails] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [RecipeHeaderId] INT             NULL,
    [StockItemId]    INT             NULL,
    [Quantity]       DECIMAL (18, 6) NULL,
    [UnitId]         INT             NULL,
    [LocationId]     INT             CONSTRAINT [DF_Inv_RecipeDetails_LocationId] DEFAULT ((0)) NOT NULL,
    [CreatedUserID]  INT             NULL,
    [CreatedDate]    DATETIME        CONSTRAINT [DF_Inv_RecipeDetails_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModUserID]  INT             NULL,
    [LastModDate]    DATETIME        NULL,
    CONSTRAINT [PK_Inv_RecipeDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

