CREATE TABLE [dbo].[OutletWiseItemCategories] (
    [Id]             INT          IDENTITY (1, 1) NOT NULL,
    [OutletCode]     VARCHAR (50) NULL,
    [ItemCategoryId] INT          NULL,
    [PropertyId]     INT          NULL,
    CONSTRAINT [PK_OutletWiseItemCategories] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

