CREATE TABLE [dbo].[SystemModules] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [ModuleID]   INT            NOT NULL,
    [ModuleName] NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.SystemModules] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

