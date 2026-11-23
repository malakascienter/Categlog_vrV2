CREATE TABLE [dbo].[ProductionConsolidateRecipeDetails] (
    [ID]                            INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]                    INT             NULL,
    [LocationID]                    INT             NULL,
    [ProductionConsolidateHeaderID] INT             NULL,
    [RecipeCode]                    VARCHAR (MAX)   NULL,
    [RecipeHeaderId]                INT             NULL,
    [ProductionItemID]              INT             NULL,
    [RecipeItemID]                  INT             NULL,
    [UnitId]                        INT             NULL,
    [Quantity]                      DECIMAL (18, 6) NULL,
    [SysDateTime]                   DATETIME        NULL,
    [UserID]                        INT             NULL,
    [MasterUnitID]                  INT             NULL,
    [ConvertedQuanity]              DECIMAL (18, 6) NULL
);


GO

