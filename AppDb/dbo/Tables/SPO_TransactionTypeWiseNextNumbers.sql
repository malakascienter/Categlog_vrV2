CREATE TABLE [dbo].[SPO_TransactionTypeWiseNextNumbers] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]         INT             NOT NULL,
    [LocationID]         VARCHAR (5)     NOT NULL,
    [TransactionType]    NVARCHAR (2)    NULL,
    [NextNumber]         DECIMAL (18, 2) NOT NULL,
    [LengthOfFormatting] INT             NOT NULL,
    CONSTRAINT [PK_dbo.SPO_TransactionTypeWiseNextNumbers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

