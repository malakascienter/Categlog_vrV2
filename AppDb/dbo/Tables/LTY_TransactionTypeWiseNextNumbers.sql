CREATE TABLE [dbo].[LTY_TransactionTypeWiseNextNumbers] (
    [Id]                 INT          IDENTITY (1, 1) NOT NULL,
    [PropertyID]         INT          NOT NULL,
    [LocationCode]       VARCHAR (20) NOT NULL,
    [TransactionType]    VARCHAR (20) NOT NULL,
    [NextNumber]         INT          NOT NULL,
    [LengthOfFormatting] INT          NOT NULL,
    CONSTRAINT [PK_LTY_TransactionTypeWiseNextNumbers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

