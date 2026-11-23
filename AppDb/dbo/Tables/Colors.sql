CREATE TABLE [dbo].[Colors] (
    [Id]        INT           IDENTITY (1, 1) NOT NULL,
    [Name]      VARCHAR (50)  NOT NULL,
    [ColorHash] NVARCHAR (50) NOT NULL,
    [RGBValue]  VARCHAR (100) NULL,
    [IsActive]  BIT           NULL
);


GO

