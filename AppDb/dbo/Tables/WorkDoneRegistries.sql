CREATE TABLE [dbo].[WorkDoneRegistries] (
    [Id]                  INT             IDENTITY (1, 1) NOT NULL,
    [ProjectID]           INT             NOT NULL,
    [DocumentNo]          NVARCHAR (MAX)  NULL,
    [BOQID]               INT             NOT NULL,
    [MainWorkID]          INT             NOT NULL,
    [WorkID]              INT             NOT NULL,
    [txnDate]             DATETIME        NOT NULL,
    [AssessedByPrcentage] BIT             NOT NULL,
    [AssessedPrcentage]   DECIMAL (18, 2) NOT NULL,
    [AssessedValue]       DECIMAL (18, 2) NOT NULL,
    [BilledValue]         DECIMAL (18, 2) NOT NULL,
    [Completed]           BIT             NOT NULL,
    [CompletedValue]      DECIMAL (18, 2) NOT NULL,
    [Status]              NVARCHAR (MAX)  NULL,
    [ApprovedByClient]    BIT             NOT NULL,
    [IsApproved]          BIT             NOT NULL,
    [IPAddress]           NVARCHAR (MAX)  NULL,
    [CreatedUserID]       INT             NOT NULL,
    [LastModUserID]       INT             NOT NULL,
    [CreatedDate]         DATETIME        NOT NULL,
    [LastModDate]         DATETIME        NOT NULL,
    [TransactionType]     NVARCHAR (MAX)  NULL,
    [LocationID]          INT             DEFAULT ((0)) NOT NULL,
    [Value]               DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [WorkValue]           DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [DepartmentID]        INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.WorkDoneRegistries] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

