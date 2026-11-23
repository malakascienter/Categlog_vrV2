CREATE TABLE [dbo].[LTYC_Policy] (
    [PolicyId]      INT            IDENTITY (1, 1) NOT NULL,
    [PropertyId]    INT            NOT NULL,
    [PolicyType]    VARCHAR (20)   NOT NULL,
    [Channel]       VARCHAR (20)   NULL,
    [Name]          NVARCHAR (150) NOT NULL,
    [WindowUnit]    VARCHAR (10)   NULL,
    [MaxCount]      INT            NULL,
    [MinGapMinutes] INT            NULL,
    [QuietStart]    TIME (0)       NULL,
    [QuietEnd]      TIME (0)       NULL,
    [TimeZoneId]    VARCHAR (64)   NULL,
    [Priority]      INT            CONSTRAINT [DF_LTYC_Policy_Priority] DEFAULT ((100)) NOT NULL,
    [IsActive]      BIT            CONSTRAINT [DF_LTYC_Policy_IsActive] DEFAULT ((1)) NOT NULL,
    [CreatedBy]     INT            NOT NULL,
    [CreatedDate]   DATETIME2 (0)  CONSTRAINT [DF_LTYC_Policy_CreatedDate] DEFAULT (sysutcdatetime()) NOT NULL,
    [ModifiedBy]    INT            NULL,
    [ModifiedDate]  DATETIME2 (0)  NULL,
    CONSTRAINT [PK_LTYC_Policy] PRIMARY KEY CLUSTERED ([PolicyId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_Policy_Property_Type]
    ON [dbo].[LTYC_Policy]([PropertyId] ASC, [PolicyType] ASC, [IsActive] ASC)
    INCLUDE([Channel], [Priority]);


GO

