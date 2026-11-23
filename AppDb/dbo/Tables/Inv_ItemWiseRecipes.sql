CREATE TABLE [dbo].[Inv_ItemWiseRecipes] (
    [Id]               INT      IDENTITY (1, 1) NOT NULL,
    [LocationId]       INT      NULL,
    [StockItemId]      INT      NULL,
    [RecipeId]         INT      NULL,
    [CompanyId]        INT      NULL,
    [Quantity]         MONEY    NULL,
    [UnitId]           INT      NULL,
    [ProductionUnitID] INT      CONSTRAINT [DF_Inv_ItemWiseRecipes_ProductionUnitID] DEFAULT ((0)) NULL,
    [CreatedUserID]    INT      NULL,
    [CreatedDate]      DATETIME CONSTRAINT [DF_Inv_ItemWiseRecipes_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModUserID]    INT      NULL,
    [LastModDate]      DATETIME NULL,
    CONSTRAINT [PK_Inv_ItemWiseRecipes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

