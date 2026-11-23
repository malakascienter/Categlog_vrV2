CREATE TABLE [dbo].[LTYJ_JourneyVersion] (
    [VersionId]         INT            IDENTITY (1, 1) NOT NULL,
    [JourneyId]         INT            NOT NULL,
    [PropertyId]        INT            NOT NULL,
    [VersionNo]         INT            NOT NULL,
    [Status]            VARCHAR (20)   CONSTRAINT [DF_LTYJ_JourneyVersion_Status] DEFAULT ('DRAFT') NOT NULL,
    [GraphJson]         NVARCHAR (MAX) NULL,
    [TriggerJson]       NVARCHAR (MAX) NULL,
    [ExitRulesJson]     NVARCHAR (MAX) NULL,
    [ReEntryPolicy]     VARCHAR (20)   CONSTRAINT [DF_LTYJ_JourneyVersion_ReEntry] DEFAULT ('ONCE_EVER') NOT NULL,
    [ReEntryPeriodDays] INT            NULL,
    [PublishedBy]       INT            NULL,
    [PublishedDate]     DATETIME2 (0)  NULL,
    [RetiredDate]       DATETIME2 (0)  NULL,
    [CreatedBy]         INT            NOT NULL,
    [CreatedDate]       DATETIME2 (0)  CONSTRAINT [DF_LTYJ_JourneyVersion_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]        INT            NULL,
    [ModifiedDate]      DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYJ_JourneyVersion] PRIMARY KEY CLUSTERED ([VersionId] ASC),
    CONSTRAINT [UQ_LTYJ_JourneyVersion_Journey_No] UNIQUE NONCLUSTERED ([JourneyId] ASC, [VersionNo] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_JourneyVersion_Journey_Status]
    ON [dbo].[LTYJ_JourneyVersion]([JourneyId] ASC, [Status] ASC)
    INCLUDE([VersionNo], [PublishedDate]);


GO

