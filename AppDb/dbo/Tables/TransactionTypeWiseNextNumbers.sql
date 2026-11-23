CREATE TABLE [dbo].[TransactionTypeWiseNextNumbers] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]         INT             NOT NULL,
    [LocationID]         INT             NOT NULL,
    [TransactionType]    NVARCHAR (2)    NULL,
    [NextNumber]         DECIMAL (18, 2) NOT NULL,
    [LengthOfFormatting] INT             NOT NULL,
    CONSTRAINT [PK_dbo.TransactionTypeWiseNextNumbers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_TransactionTypeWiseNextNumbers_Location_Type]
    ON [dbo].[TransactionTypeWiseNextNumbers]([LocationID] ASC, [TransactionType] ASC, [PropertyID] ASC)
    INCLUDE([NextNumber], [LengthOfFormatting]);


GO

