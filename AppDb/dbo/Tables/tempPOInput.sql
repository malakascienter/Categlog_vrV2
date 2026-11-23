CREATE TABLE [dbo].[tempPOInput] (
    [id]         INT      IDENTITY (1, 1) NOT NULL,
    [xmldata]    XML      NULL,
    [LogDate]    DATETIME CONSTRAINT [DF_tempPOInput_LogDate] DEFAULT (getdate()) NOT NULL,
    [POHeaderID] INT      NULL
);


GO

