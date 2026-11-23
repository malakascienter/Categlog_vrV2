CREATE TABLE [dbo].[SubModulesL1] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [ParentModuleId] INT            NOT NULL,
    [SubModulesId]   INT            NOT NULL,
    [Name]           NVARCHAR (MAX) NULL,
    [Icon]           NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.SubModulesL1] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

