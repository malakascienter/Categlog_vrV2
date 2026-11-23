CREATE TABLE [dbo].[TempRequestHeader] (
    [XX]      XML      NULL,
    [logDate] DATETIME CONSTRAINT [DF_TempRequestHeader_logDate] DEFAULT (getdate()) NULL
);


GO

