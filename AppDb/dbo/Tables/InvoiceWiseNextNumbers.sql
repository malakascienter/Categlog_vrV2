CREATE TABLE [dbo].[InvoiceWiseNextNumbers] (
    [Id]                 INT         IDENTITY (1, 1) NOT NULL,
    [DepartmentId]       INT         NOT NULL,
    [Prefix]             VARCHAR (2) NOT NULL,
    [NextNo]             INT         NOT NULL,
    [LengthOfFormatting] INT         NOT NULL
);


GO

