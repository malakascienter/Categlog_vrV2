CREATE TABLE [dbo].[ModuleWisePayTypeMapping] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [Name]         VARCHAR (50) NULL,
    [PayCode]      VARCHAR (10) NULL,
    [DivisionCode] NCHAR (10)   NULL,
    [DivisionName] VARCHAR (50) NULL
);


GO

