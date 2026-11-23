CREATE TABLE [dbo].[AutoCodes] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [FileType]        VARCHAR (10) NULL,
    [CodeLength]      INT          NULL,
    [Prefix]          VARCHAR (5)  NULL,
    [IsPrefixAllowed] BIT          NULL
);


GO

