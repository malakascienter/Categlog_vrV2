CREATE TABLE [dbo].[tempGrnTxn] (
    [Id]      INT      IDENTITY (1, 1) NOT NULL,
    [LogDate] DATETIME CONSTRAINT [DF_tempGrnTxn_LogDate] DEFAULT (getdate()) NOT NULL,
    [XMLData] XML      NULL
);


GO

