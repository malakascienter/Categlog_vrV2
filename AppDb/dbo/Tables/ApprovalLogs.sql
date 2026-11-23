CREATE TABLE [dbo].[ApprovalLogs] (
    [ApprovalLogID]       INT            IDENTITY (1, 1) NOT NULL,
    [SeqID]               INT            NOT NULL,
    [TransactionID]       INT            NOT NULL,
    [ApprovalLevelID]     INT            NOT NULL,
    [TransactionHeaderID] INT            NOT NULL,
    [PropertyID]          INT            NOT NULL,
    [LocationID]          INT            NOT NULL,
    [ApprovalUserID]      INT            NULL,
    [ApprovalDate]        DATETIME       NULL,
    [IsComplete]          BIT            NOT NULL,
    [DocStatus]           NVARCHAR (1)   NULL,
    [IPAddress]           NVARCHAR (MAX) NULL,
    [CreatedUserID]       INT            NOT NULL,
    [LastModUserID]       INT            NOT NULL,
    [CreatedDate]         DATETIME       NOT NULL,
    [LastModDate]         DATETIME       NOT NULL,
    [Remarks]             VARCHAR (500)  NULL,
    [SendMail]            BIT            DEFAULT ((0)) NULL,
    [Id]                  AS             ([ApprovalLogID]) PERSISTED NOT NULL,
    [SendSMS]             BIT            CONSTRAINT [DF_ApprovalLogs_SendSMS] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.ApprovalLogs] PRIMARY KEY CLUSTERED ([ApprovalLogID] ASC)
);


GO

CREATE NONCLUSTERED INDEX [ApprovalLogs_TransactionID_PropertyID]
    ON [dbo].[ApprovalLogs]([TransactionID] ASC, [PropertyID] ASC, [LocationID] ASC);


GO

CREATE NONCLUSTERED INDEX [ApprovalLogs_TransactionID]
    ON [dbo].[ApprovalLogs]([TransactionID] ASC, [IsComplete] ASC)
    INCLUDE([SeqID], [TransactionHeaderID], [PropertyID]);


GO

CREATE NONCLUSTERED INDEX [ApprovalLogs_IsComplete]
    ON [dbo].[ApprovalLogs]([TransactionID] ASC, [TransactionHeaderID] ASC, [IsComplete] ASC)
    INCLUDE([SeqID], [PropertyID]);


GO

