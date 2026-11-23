CREATE TABLE [dbo].[DayEndPostingLog] (
    [PropertyId] INT           NULL,
    [Date]       DATETIME      NULL,
    [LogTime]    DATETIME      CONSTRAINT [DF_DayEndPostingLog_LogTime] DEFAULT (getdate()) NOT NULL,
    [Remark]     VARCHAR (200) NULL
);


GO

