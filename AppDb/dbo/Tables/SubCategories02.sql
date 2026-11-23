CREATE TABLE [dbo].[SubCategories02] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [Description]   NVARCHAR (MAX) NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [CategoryId]    INT            CONSTRAINT [DF_SubCategories02_CategoryId] DEFAULT ((0)) NULL,
    [SubCategoryId] INT            CONSTRAINT [DF_SubCategories02_SubCategoryId] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.SubCategories02] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

