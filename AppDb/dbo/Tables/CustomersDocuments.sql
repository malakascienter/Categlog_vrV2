CREATE TABLE [dbo].[CustomersDocuments] (
    [ID]   INT           IDENTITY (1, 1) NOT NULL,
    [Name] VARCHAR (500) NOT NULL,
    [Type] INT           CONSTRAINT [DF_CustomersDocuments_Type] DEFAULT ((1)) NOT NULL
);


GO

