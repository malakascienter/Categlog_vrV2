CREATE TABLE [dbo].[SendTransactionWiseEmailS_Log] (
    [ID]              INT      IDENTITY (1, 1) NOT NULL,
    [TransactionType] CHAR (2) NULL,
    [HeaderID]        INT      NULL,
    [LocationID]      INT      NULL,
    [PropertyID]      INT      NULL,
    [Operation]       CHAR (2) NULL,
    [SysDate]         DATETIME NULL
);


GO

