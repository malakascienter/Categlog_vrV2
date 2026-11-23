CREATE TABLE [dbo].[LTYJ_EnrollmentWatermark] (
    [JourneyId]         INT           NOT NULL,
    [PropertyId]        INT           NOT NULL,
    [LastEvaluatedDate] DATE          NULL,
    [LastRunAt]         DATETIME2 (0) NULL,
    [LastEnrolledCount] INT           CONSTRAINT [DF_LTYJ_EnrollmentWatermark_Count] DEFAULT ((0)) NOT NULL,
    [LockedBy]          VARCHAR (100) NULL,
    [LockedUntil]       DATETIME2 (3) NULL,
    CONSTRAINT [PK_LTYJ_EnrollmentWatermark] PRIMARY KEY CLUSTERED ([JourneyId] ASC, [PropertyId] ASC)
);


GO

