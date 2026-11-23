CREATE TABLE [dbo].[LTYC_BrazeSync] (
    [SyncId]              INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]          INT             NOT NULL,
    [SegmentId]           INT             NOT NULL,
    [Status]              VARCHAR (30)    CONSTRAINT [DF_LTYC_BrazeSync_Status] DEFAULT ('QUEUED') NOT NULL,
    [Mode]                VARCHAR (10)    CONSTRAINT [DF_LTYC_BrazeSync_Mode] DEFAULT ('MOCK') NOT NULL,
    [ExternalIdAttribute] VARCHAR (60)    CONSTRAINT [DF_LTYC_BrazeSync_ExtIdAttr] DEFAULT ('MembershipCode') NOT NULL,
    [SnapshotVersion]     INT             CONSTRAINT [DF_LTYC_BrazeSync_Snapshot] DEFAULT ((0)) NOT NULL,
    [TotalCount]          INT             CONSTRAINT [DF_LTYC_BrazeSync_Total] DEFAULT ((0)) NOT NULL,
    [SuccessCount]        INT             CONSTRAINT [DF_LTYC_BrazeSync_Success] DEFAULT ((0)) NOT NULL,
    [FailedCount]         INT             CONSTRAINT [DF_LTYC_BrazeSync_Failed] DEFAULT ((0)) NOT NULL,
    [SkippedCount]        INT             CONSTRAINT [DF_LTYC_BrazeSync_Skipped] DEFAULT ((0)) NOT NULL,
    [StartedAt]           DATETIME2 (0)   NULL,
    [CompletedAt]         DATETIME2 (0)   NULL,
    [ErrorSummary]        NVARCHAR (2000) NULL,
    [TriggeredBy]         INT             NULL,
    [CreatedDate]         DATETIME2 (0)   CONSTRAINT [DF_LTYC_BrazeSync_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_BrazeSync] PRIMARY KEY CLUSTERED ([SyncId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_BrazeSync_Segment]
    ON [dbo].[LTYC_BrazeSync]([SegmentId] ASC, [StartedAt] DESC)
    INCLUDE([Status], [Mode], [TotalCount], [SuccessCount], [FailedCount]);


GO

