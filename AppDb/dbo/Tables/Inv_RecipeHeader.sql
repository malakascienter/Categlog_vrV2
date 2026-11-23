CREATE TABLE [dbo].[Inv_RecipeHeader] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [RecipeCode]    NVARCHAR (50)  NULL,
    [RecipeName]    NVARCHAR (250) NULL,
    [IsActive]      BIT            NULL,
    [CompanyId]     INT            NULL,
    [UnitId]        INT            NULL,
    [CreatedUserID] INT            NULL,
    [CreatedDate]   DATETIME       CONSTRAINT [DF_Inv_RecipeHeader_CreatedDate] DEFAULT (getdate()) NULL,
    [LastModUserID] INT            NULL,
    [LastModDate]   DATETIME       NULL,
    CONSTRAINT [PK_Inv_RecipeHeader] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

