CREATE TABLE [dbo].[ProjectWiseSubcontractorsDetails] (
    [Id]                       INT             IDENTITY (1, 1) NOT NULL,
    [PWSID]                    INT             NOT NULL,
    [UnitDesignatorID]         INT             NOT NULL,
    [Qty]                      DECIMAL (18, 2) NOT NULL,
    [Rate]                     DECIMAL (18, 2) NOT NULL,
    [AdavanceAmount]           DECIMAL (18, 2) NOT NULL,
    [RetentionsPeriodInMonths] DECIMAL (18, 2) NOT NULL,
    [Retentions]               DECIMAL (18, 2) NOT NULL,
    [Total]                    DECIMAL (18, 2) NOT NULL,
    [IPAddress]                NVARCHAR (MAX)  NULL,
    [CreatedUserID]            INT             NOT NULL,
    [LastModUserID]            INT             NOT NULL,
    [CreatedDate]              DATETIME        NOT NULL,
    [LastModDate]              DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.ProjectWiseSubcontractorsDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

