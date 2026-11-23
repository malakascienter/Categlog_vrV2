CREATE TABLE [dbo].[App_AuditLog] (
    [Id]           BIGINT         IDENTITY (1, 1) NOT NULL,
    [PropertyId]   INT            NOT NULL,
    [EntityName]   VARCHAR (100)  NOT NULL,
    [RecordId]     VARCHAR (50)   NOT NULL,
    [RecordLabel]  NVARCHAR (200) NULL,
    [Action]       CHAR (1)       NOT NULL,
    [UserId]       INT            NOT NULL,
    [Username]     NVARCHAR (100) NULL,
    [LoggedAt]     DATETIME2 (0)  CONSTRAINT [DF_App_AuditLog_LoggedAt] DEFAULT (getdate()) NOT NULL,
    [LoggedAtUtc]  DATETIME2 (0)  CONSTRAINT [DF_App_AuditLog_LoggedAtUtc] DEFAULT (getutcdate()) NOT NULL,
    [SourceScreen] VARCHAR (100)  NULL,
    CONSTRAINT [PK_App_AuditLog] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [CK_App_AuditLog_Action] CHECK ([Action]='D' OR [Action]='U' OR [Action]='I')
);


GO

CREATE NONCLUSTERED INDEX [IX_App_AuditLog_User_Date]
    ON [dbo].[App_AuditLog]([PropertyId] ASC, [UserId] ASC, [LoggedAt] DESC);


GO

CREATE NONCLUSTERED INDEX [IX_App_AuditLog_Entity_Record]
    ON [dbo].[App_AuditLog]([PropertyId] ASC, [EntityName] ASC, [RecordId] ASC, [Id] DESC);


GO

CREATE NONCLUSTERED INDEX [IX_App_AuditLog_Date]
    ON [dbo].[App_AuditLog]([PropertyId] ASC, [LoggedAt] DESC);


GO

