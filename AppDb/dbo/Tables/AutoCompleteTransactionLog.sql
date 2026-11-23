CREATE TABLE [dbo].[AutoCompleteTransactionLog] (
    [Id]                  INT              IDENTITY (1, 1) NOT NULL,
    [RunId]               UNIQUEIDENTIFIER NOT NULL,
    [RunDate]             DATE             NOT NULL,
    [TransactionTypeId]   INT              NULL,
    [TransactionTypeCode] NVARCHAR (20)    NULL,
    [SourceTable]         VARCHAR (30)     NOT NULL,
    [ReferenceID]         INT              NOT NULL,
    [DocumentDate]        DATETIME         NULL,
    [CompletedOn]         DATETIME         CONSTRAINT [DF_AutoCompleteTransactionLog_CompletedOn] DEFAULT (getdate()) NOT NULL,
    [CompletedDate]       DATE             NULL,
    [CompletedTime]       TIME (0)         NULL,
    CONSTRAINT [PK_AutoCompleteTransactionLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_AutoCompleteTransactionLog_RunId]
    ON [dbo].[AutoCompleteTransactionLog]([RunId] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_AutoCompleteTransactionLog_Reference]
    ON [dbo].[AutoCompleteTransactionLog]([SourceTable] ASC, [ReferenceID] ASC);


GO

