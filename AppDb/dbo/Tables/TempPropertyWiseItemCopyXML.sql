CREATE TABLE [dbo].[TempPropertyWiseItemCopyXML] (
    [Id]      INT      IDENTITY (1, 1) NOT NULL,
    [LogDate] DATETIME CONSTRAINT [DF_TempPropertyWiseItemCopyXML_LogDate] DEFAULT (getdate()) NOT NULL,
    [XMLData] XML      NULL
);


GO

