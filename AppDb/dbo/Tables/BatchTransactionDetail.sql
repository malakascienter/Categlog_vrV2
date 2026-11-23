CREATE TABLE [dbo].[BatchTransactionDetail] (
    [Id]                       INT      IDENTITY (1, 1) NOT NULL,
    [BatchTransactionHeaderID] INT      NULL,
    [TransactionID]            INT      NULL,
    [CreatedUserID]            INT      NULL,
    [CreatedDate]              DATETIME NULL
);


GO

