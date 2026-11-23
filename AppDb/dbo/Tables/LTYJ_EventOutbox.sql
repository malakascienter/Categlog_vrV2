CREATE TABLE [dbo].[LTYJ_EventOutbox] (
    [EventId]         BIGINT          IDENTITY (1, 1) NOT NULL,
    [EventType]       VARCHAR (40)    NOT NULL,
    [MemberId]        INT             NULL,
    [PropertyId]      INT             NOT NULL,
    [EntityId]        INT             NULL,
    [PayloadJson]     NVARCHAR (MAX)  NULL,
    [OccurredAt]      DATETIME2 (0)   CONSTRAINT [DF_LTYJ_EventOutbox_OccurredAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [ProcessedAt]     DATETIME2 (0)   NULL,
    [ProcessAttempts] INT             CONSTRAINT [DF_LTYJ_EventOutbox_Attempts] DEFAULT ((0)) NOT NULL,
    [LastError]       NVARCHAR (2000) NULL,
    CONSTRAINT [PK_LTYJ_EventOutbox] PRIMARY KEY CLUSTERED ([EventId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_EventOutbox_Unprocessed]
    ON [dbo].[LTYJ_EventOutbox]([EventId] ASC)
    INCLUDE([EventType], [MemberId], [PropertyId], [EntityId], [OccurredAt]) WHERE ([ProcessedAt] IS NULL);


GO

