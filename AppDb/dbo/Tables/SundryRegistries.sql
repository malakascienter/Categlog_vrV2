CREATE TABLE [dbo].[SundryRegistries] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [BOQId]         INT             NOT NULL,
    [DepId]         INT             NOT NULL,
    [SundryAmount]  DECIMAL (18, 2) NOT NULL,
    [RequestAmount] DECIMAL (18, 2) NOT NULL,
    [IssueAmount]   DECIMAL (18, 2) NOT NULL,
    [BalanceAmount] DECIMAL (18, 2) NOT NULL,
    CONSTRAINT [PK_SundryRegistries] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

