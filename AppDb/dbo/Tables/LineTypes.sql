CREATE TABLE [dbo].[LineTypes] (
    [ID]             INT          IDENTITY (1, 1) NOT NULL,
    [Description]    VARCHAR (50) NULL,
    [NumberOfColums] INT          NULL,
    [PrintType]      INT          CONSTRAINT [DF_LineTypes_PrintType] DEFAULT ((1)) NOT NULL
);


GO

