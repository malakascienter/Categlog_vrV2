CREATE TABLE [dbo].[OutSourceLabourHeaders] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [TxnNumber]       NVARCHAR (MAX)  NULL,
    [TxnDate]         DATETIME        NOT NULL,
    [ProjectId]       INT             NOT NULL,
    [BOQId]           INT             NOT NULL,
    [LaborMasterId]   INT             NOT NULL,
    [Amount]          DECIMAL (18, 2) NOT NULL,
    [CrNo]            NVARCHAR (MAX)  NULL,
    [Journals]        NVARCHAR (MAX)  NULL,
    [Status]          NVARCHAR (MAX)  NULL,
    [Completed]       BIT             NOT NULL,
    [IsApproved]      BIT             NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    [PropertyID]      INT             DEFAULT ((0)) NOT NULL,
    [LocationID]      INT             DEFAULT ((0)) NOT NULL,
    [TransactionType] NVARCHAR (MAX)  NULL,
    CONSTRAINT [PK_dbo.OutSourceLabourHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

