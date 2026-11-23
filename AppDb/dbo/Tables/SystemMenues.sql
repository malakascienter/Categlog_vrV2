CREATE TABLE [dbo].[SystemMenues] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [MainModuleId] INT            NOT NULL,
    [SubModuleId]  INT            NOT NULL,
    [FormID]       INT            NOT NULL,
    [RoutePath]    VARCHAR (255)  NULL,
    [Icon]         NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.SystemMenues] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

