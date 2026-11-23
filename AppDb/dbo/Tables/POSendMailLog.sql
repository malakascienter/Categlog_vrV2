CREATE TABLE [dbo].[POSendMailLog] (
    [Id]         INT            IDENTITY (1, 1) NOT NULL,
    [POHeaderID] INT            NOT NULL,
    [Message]    NVARCHAR (500) NULL,
    [IsSendMail] BIT            NULL,
    [LogDate]    DATETIME       CONSTRAINT [DF_POSendMailLog_LogDate] DEFAULT (getdate()) NOT NULL,
    [PropertyID] INT            NULL
);


GO

