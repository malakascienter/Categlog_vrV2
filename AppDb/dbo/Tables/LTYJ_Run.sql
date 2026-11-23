CREATE TABLE [dbo].[LTYJ_Run] (
    [RunId]          BIGINT          IDENTITY (1, 1) NOT NULL,
    [JourneyId]      INT             NOT NULL,
    [VersionId]      INT             NOT NULL,
    [MemberId]       INT             NOT NULL,
    [PropertyId]     INT             NOT NULL,
    [Status]         VARCHAR (20)    CONSTRAINT [DF_LTYJ_Run_Status] DEFAULT ('ACTIVE') NOT NULL,
    [CurrentNodeKey] VARCHAR (50)    NULL,
    [NextRunAt]      DATETIME2 (3)   NULL,
    [ContextJson]    NVARCHAR (MAX)  NULL,
    [EnteredDate]    DATE            NOT NULL,
    [EnteredAt]      DATETIME2 (0)   CONSTRAINT [DF_LTYJ_Run_EnteredAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [EndedAt]        DATETIME2 (0)   NULL,
    [ExitReason]     VARCHAR (50)    NULL,
    [LockedBy]       VARCHAR (100)   NULL,
    [LockedUntil]    DATETIME2 (3)   NULL,
    [AttemptCount]   INT             CONSTRAINT [DF_LTYJ_Run_AttemptCount] DEFAULT ((0)) NOT NULL,
    [LastError]      NVARCHAR (2000) NULL,
    CONSTRAINT [PK_LTYJ_Run] PRIMARY KEY CLUSTERED ([RunId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_Run_Member_Status]
    ON [dbo].[LTYJ_Run]([MemberId] ASC, [Status] ASC)
    INCLUDE([RunId], [JourneyId], [VersionId], [CurrentNodeKey]);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYJ_Run_Journey_Member_Day]
    ON [dbo].[LTYJ_Run]([JourneyId] ASC, [MemberId] ASC, [EnteredDate] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_Run_Journey_Status]
    ON [dbo].[LTYJ_Run]([JourneyId] ASC, [Status] ASC)
    INCLUDE([VersionId], [EnteredAt], [EndedAt], [ExitReason]);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_Run_Due]
    ON [dbo].[LTYJ_Run]([NextRunAt] ASC)
    INCLUDE([RunId], [JourneyId], [VersionId], [MemberId], [PropertyId], [CurrentNodeKey], [LockedUntil]) WHERE ([Status] IN ('ACTIVE', 'WAITING'));


GO

