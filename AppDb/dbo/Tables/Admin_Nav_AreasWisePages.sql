CREATE TABLE [dbo].[Admin_Nav_AreasWisePages] (
    [Id]          INT            NOT NULL,
    [RootPageId]  INT            NULL,
    [AreaId]      INT            NULL,
    [Name]        NVARCHAR (50)  NULL,
    [Url]         NVARCHAR (250) NULL,
    [Icon]        NVARCHAR (50)  NULL,
    [ImageURL]    NVARCHAR (100) NULL,
    [DispayOrder] INT            NULL,
    [IsActive]    BIT            NULL,
    CONSTRAINT [PK_Admin_Nav_TopNavigationWisePages] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

