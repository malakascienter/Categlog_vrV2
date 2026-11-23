CREATE TABLE [dbo].[LTYC_Segment] (
    [SegmentId]          INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]         INT             NOT NULL,
    [Name]               NVARCHAR (150)  NOT NULL,
    [Description]        NVARCHAR (1000) NULL,
    [RootOperator]       VARCHAR (3)     CONSTRAINT [DF_LTYC_Segment_RootOperator] DEFAULT ('AND') NOT NULL,
    [RefreshMode]        VARCHAR (20)    CONSTRAINT [DF_LTYC_Segment_RefreshMode] DEFAULT ('SCHEDULED') NOT NULL,
    [RefreshCron]        VARCHAR (100)   NULL,
    [LastEstimatedCount] INT             NULL,
    [LastEstimatedAt]    DATETIME2 (0)   NULL,
    [LastRefreshedAt]    DATETIME2 (0)   NULL,
    [LastRefreshMs]      INT             NULL,
    [SnapshotVersion]    INT             CONSTRAINT [DF_LTYC_Segment_SnapshotVersion] DEFAULT ((0)) NOT NULL,
    [IsActive]           BIT             CONSTRAINT [DF_LTYC_Segment_IsActive] DEFAULT ((1)) NOT NULL,
    [IsDeleted]          BIT             CONSTRAINT [DF_LTYC_Segment_IsDeleted] DEFAULT ((0)) NOT NULL,
    [CreatedBy]          INT             NOT NULL,
    [CreatedDate]        DATETIME2 (0)   CONSTRAINT [DF_LTYC_Segment_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]         INT             NULL,
    [ModifiedDate]       DATETIME2 (0)   NULL,
    CONSTRAINT [PK_LTYC_Segment] PRIMARY KEY CLUSTERED ([SegmentId] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_LTYC_Segment_Property_Name]
    ON [dbo].[LTYC_Segment]([PropertyId] ASC, [Name] ASC) WHERE ([IsDeleted]=(0));


GO

