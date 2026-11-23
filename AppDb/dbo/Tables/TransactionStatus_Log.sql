CREATE TABLE [dbo].[TransactionStatus_Log] (
    [ID]              INT          IDENTITY (1, 1) NOT NULL,
    [HeaderID]        INT          NULL,
    [TransactionType] NCHAR (10)   NULL,
    [SysDate]         DATETIME     NULL,
    [Status]          VARCHAR (50) NULL,
    [UserID]          INT          NULL,
    [Module]          VARCHAR (50) NULL
);


GO

