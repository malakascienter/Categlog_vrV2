CREATE TABLE [dbo].[Currency] (
    [Id]           INT             NOT NULL,
    [CurrencyId]   INT             NOT NULL,
    [ExchangeRate] DECIMAL (18, 2) NOT NULL,
    [Date]         DATE            NOT NULL,
    CONSTRAINT [PK_Currency] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

