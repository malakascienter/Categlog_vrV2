CREATE TABLE [dbo].[LTY_PointTransactionType] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [TransactionType] VARCHAR (MAX) NOT NULL,
    [Code]            VARCHAR (10)  NOT NULL,
    CONSTRAINT [PK_LTY_PointTransactionType] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

