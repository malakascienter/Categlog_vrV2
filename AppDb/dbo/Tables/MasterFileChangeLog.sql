CREATE TABLE [dbo].[MasterFileChangeLog] (
    [ID]             INT           IDENTITY (1, 1) NOT NULL,
    [MasterFileName] VARCHAR (200) NULL,
    [UserID]         INT           NULL,
    [logTime]        DATETIME      CONSTRAINT [DF_MasterFileChangeLog_logTime] DEFAULT (getdate()) NOT NULL,
    [Narration]      VARCHAR (500) NULL
);


GO

