CREATE TABLE [dbo].[ProjectDetails] (
    [Id]                             INT             IDENTITY (1, 1) NOT NULL,
    [ClientID]                       INT             NOT NULL,
    [ProjectName]                    NVARCHAR (200)  NULL,
    [HaveBOQ]                        BIT             NOT NULL,
    [ProjectManagerEmail]            NVARCHAR (100)  NULL,
    [PlannedStartingDate]            DATETIME        NOT NULL,
    [PlannedEndingDate]              DATETIME        NOT NULL,
    [ActualStratingDate]             DATETIME        NOT NULL,
    [ActualEndingDate]               DATETIME        NOT NULL,
    [IPAddress]                      NVARCHAR (MAX)  NULL,
    [CreatedUserID]                  INT             NOT NULL,
    [LastModUserID]                  INT             NOT NULL,
    [CreatedDate]                    DATETIME        NOT NULL,
    [LastModDate]                    DATETIME        NOT NULL,
    [Projecstatus]                   BIT             DEFAULT ((0)) NOT NULL,
    [ProjectCode]                    NVARCHAR (MAX)  NULL,
    [ClientProjectManagerName]       NVARCHAR (MAX)  NULL,
    [ClientProjectManagerPhone]      NVARCHAR (MAX)  NULL,
    [ClientProjectManagerEmail]      NVARCHAR (MAX)  NULL,
    [AdvanceRecoveryPercentage]      DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [ProjectRetentionPercentage]     DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [BillRetentionPercentage]        DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DefectLiabilityPeriod]          INT             DEFAULT ((0)) NOT NULL,
    [RetentionReleaseAtCloser]       DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [RetentionReleaseAtDefectPeriod] DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [Basecurrency]                   INT             DEFAULT ((0)) NOT NULL,
    [ExchangeRate]                   DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.ProjectDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

