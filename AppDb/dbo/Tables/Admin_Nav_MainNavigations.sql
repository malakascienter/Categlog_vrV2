CREATE TABLE [dbo].[Admin_Nav_MainNavigations] (
    [Id]           INT            NOT NULL,
    [Name]         NVARCHAR (50)  NOT NULL,
    [Description]  NVARCHAR (250) NULL,
    [Url]          NVARCHAR (100) NULL,
    [DisplayOrder] INT            NULL,
    [IsActive]     BIT            NULL,
    [TemplateId]   INT            NULL,
    CONSTRAINT [PK_Admin_Nav_TopNavigations] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

