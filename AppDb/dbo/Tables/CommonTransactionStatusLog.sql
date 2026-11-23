CREATE TABLE [dbo].[CommonTransactionStatusLog] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [CompanyID]           INT           NULL,
    [TransactionID]       INT           NULL,
    [TransactionHeaderID] INT           NULL,
    [TransactionStatusID] INT           NULL,
    [Status]              CHAR (1)      NULL,
    [CreatedDate]         DATETIME      CONSTRAINT [DF_CommonTransactionStatusLog_CreatedDate] DEFAULT (getdate()) NULL,
    [UserProfileID]       INT           NULL,
    [RejectedReason]      VARCHAR (MAX) NULL
);


GO

