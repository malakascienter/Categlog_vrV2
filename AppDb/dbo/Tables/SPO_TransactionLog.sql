CREATE TABLE [dbo].[SPO_TransactionLog] (
    [Id]              INT            IDENTITY (1, 1) NOT NULL,
    [LogDate]         DATETIME       CONSTRAINT [DF_SPO_TransactionLog_LogDate] DEFAULT (getdate()) NOT NULL,
    [TransactionType] VARCHAR (50)   NULL,
    [LogData]         NVARCHAR (MAX) NULL,
    [TransactionID]   INT            NULL,
    [Reference1]      VARCHAR (MAX)  NULL,
    [Reference2]      VARCHAR (MAX)  NULL
);


GO

