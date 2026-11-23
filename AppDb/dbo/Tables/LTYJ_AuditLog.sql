CREATE TABLE [dbo].[LTYJ_AuditLog] (
    [AuditId]     BIGINT          IDENTITY (1, 1) NOT NULL,
    [PropertyId]  INT             NOT NULL,
    [EntityType]  VARCHAR (40)    NOT NULL,
    [EntityId]    INT             NULL,
    [Action]      VARCHAR (40)    NOT NULL,
    [ActorUserId] INT             NULL,
    [ActorIp]     VARCHAR (45)    NULL,
    [BeforeJson]  NVARCHAR (MAX)  NULL,
    [AfterJson]   NVARCHAR (MAX)  NULL,
    [Notes]       NVARCHAR (1000) NULL,
    [CreatedDate] DATETIME2 (0)   CONSTRAINT [DF_LTYJ_AuditLog_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYJ_AuditLog] PRIMARY KEY CLUSTERED ([AuditId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_AuditLog_Entity]
    ON [dbo].[LTYJ_AuditLog]([EntityType] ASC, [EntityId] ASC, [CreatedDate] ASC)
    INCLUDE([Action], [ActorUserId]);


GO

