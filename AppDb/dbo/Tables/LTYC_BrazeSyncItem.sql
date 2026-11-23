CREATE TABLE [dbo].[LTYC_BrazeSyncItem] (
    [ItemId]       BIGINT          IDENTITY (1, 1) NOT NULL,
    [SyncId]       INT             NOT NULL,
    [MemberId]     INT             NOT NULL,
    [ExternalId]   NVARCHAR (100)  NULL,
    [Status]       VARCHAR (20)    CONSTRAINT [DF_LTYC_BrazeSyncItem_Status] DEFAULT ('PENDING') NOT NULL,
    [SkipReason]   VARCHAR (40)    NULL,
    [AttemptCount] INT             CONSTRAINT [DF_LTYC_BrazeSyncItem_Attempts] DEFAULT ((0)) NOT NULL,
    [HttpStatus]   INT             NULL,
    [ErrorMessage] NVARCHAR (1000) NULL,
    [SentAt]       DATETIME2 (0)   NULL,
    CONSTRAINT [PK_LTYC_BrazeSyncItem] PRIMARY KEY CLUSTERED ([ItemId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_BrazeSyncItem_Sync_Status]
    ON [dbo].[LTYC_BrazeSyncItem]([SyncId] ASC, [Status] ASC)
    INCLUDE([MemberId], [ExternalId], [AttemptCount], [ErrorMessage]);


GO

