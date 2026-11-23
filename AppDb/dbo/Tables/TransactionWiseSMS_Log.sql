CREATE TABLE [dbo].[TransactionWiseSMS_Log] (
    [ID]              INT            IDENTITY (1, 1) NOT NULL,
    [TransactionType] CHAR (3)       NULL,
    [PropertyID]      INT            NULL,
    [LocationID]      INT            NULL,
    [HeaderID]        INT            NULL,
    [ContactNo]       NVARCHAR (20)  NULL,
    [RecivedUserID]   INT            NULL,
    [Message]         NVARCHAR (MAX) NULL,
    [Status]          CHAR (1)       NULL,
    [CreatedDateTime] DATETIME       NULL,
    [MsgSentTime]     DATETIME       NULL,
    [Response]        NVARCHAR (MAX) NULL,
    [ReTryCount]      INT            CONSTRAINT [DF_TransactionWiseSMS_Log_ReTryCount] DEFAULT ((0)) NULL,
    [ApprovalLogID]   INT            NULL
);


GO

