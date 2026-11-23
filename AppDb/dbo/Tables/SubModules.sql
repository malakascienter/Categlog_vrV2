CREATE TABLE [dbo].[SubModules] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [Name]           NVARCHAR (MAX) NULL,
    [ParentModuleId] INT            NOT NULL,
    [Icon]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.SubModules] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

