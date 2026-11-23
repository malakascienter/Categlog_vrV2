CREATE TABLE [dbo].[PrintingCommands] (
    [ID]                INT          IDENTITY (1, 1) NOT NULL,
    [Description]       VARCHAR (50) NULL,
    [Bolt]              VARCHAR (50) NULL,
    [Italic]            VARCHAR (50) NULL,
    [Underline]         VARCHAR (50) NULL,
    [strikeOff]         VARCHAR (50) NULL,
    [AlignTo]           VARCHAR (50) NULL,
    [DoubleWidth]       VARCHAR (50) NULL,
    [DoubleHeight]      VARCHAR (50) NULL,
    [Rest]              VARCHAR (50) NULL,
    [CharactersPerLine] INT          NULL
);


GO

