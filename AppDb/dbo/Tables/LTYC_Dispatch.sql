CREATE TABLE [dbo].[LTYC_Dispatch] (
    [DispatchId]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [PropertyId]        INT             NOT NULL,
    [MemberId]          INT             NULL,
    [Channel]           VARCHAR (20)    NOT NULL,
    [SourceType]        VARCHAR (20)    NOT NULL,
    [SourceId]          INT             NULL,
    [RunId]             BIGINT          NULL,
    [StepExecutionId]   BIGINT          NULL,
    [TemplateId]        INT             NULL,
    [VariantKey]        VARCHAR (20)    NULL,
    [Status]            VARCHAR (20)    CONSTRAINT [DF_LTYC_Dispatch_Status] DEFAULT ('QUEUED') NOT NULL,
    [SuppressReason]    VARCHAR (40)    NULL,
    [Recipient]         NVARCHAR (300)  NULL,
    [ProviderMessageId] VARCHAR (200)   NULL,
    [ProviderName]      VARCHAR (50)    NULL,
    [ScheduledFor]      DATETIME2 (3)   NULL,
    [SentAt]            DATETIME2 (0)   NULL,
    [AttemptCount]      INT             CONSTRAINT [DF_LTYC_Dispatch_AttemptCount] DEFAULT ((0)) NOT NULL,
    [LastError]         NVARCHAR (2000) NULL,
    [IdempotencyKey]    VARCHAR (120)   NOT NULL,
    [CreatedDate]       DATETIME2 (0)   CONSTRAINT [DF_LTYC_Dispatch_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_Dispatch] PRIMARY KEY CLUSTERED ([DispatchId] ASC),
    CONSTRAINT [UQ_LTYC_Dispatch_Idempotency] UNIQUE NONCLUSTERED ([IdempotencyKey] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_Dispatch_ProviderMessageId]
    ON [dbo].[LTYC_Dispatch]([ProviderMessageId] ASC)
    INCLUDE([DispatchId], [MemberId], [Channel]) WHERE ([ProviderMessageId] IS NOT NULL);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_Dispatch_Pending]
    ON [dbo].[LTYC_Dispatch]([ScheduledFor] ASC)
    INCLUDE([DispatchId], [MemberId], [Channel], [TemplateId], [PropertyId]) WHERE ([Status] IN ('QUEUED', 'DEFERRED'));


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_Dispatch_Source]
    ON [dbo].[LTYC_Dispatch]([SourceType] ASC, [SourceId] ASC, [Channel] ASC, [Status] ASC)
    INCLUDE([SentAt], [SuppressReason], [VariantKey]);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_Dispatch_Member_Channel_Sent]
    ON [dbo].[LTYC_Dispatch]([MemberId] ASC, [Channel] ASC, [SentAt] ASC)
    INCLUDE([SourceType], [Status]);


GO

