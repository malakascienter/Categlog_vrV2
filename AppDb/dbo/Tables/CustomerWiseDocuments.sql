CREATE TABLE [dbo].[CustomerWiseDocuments] (
    [CustomerID]     INT NULL,
    [DocumentID]     INT NULL,
    [Submited]       BIT CONSTRAINT [DF_CustomerWiseDocuments_Submited] DEFAULT ((0)) NOT NULL,
    [documentPathId] INT NULL,
    [Id]             INT IDENTITY (1, 1) NOT NULL
);


GO

