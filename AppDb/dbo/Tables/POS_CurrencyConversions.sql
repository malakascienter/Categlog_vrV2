CREATE TABLE [dbo].[POS_CurrencyConversions] (
    [Id]             INT      IDENTITY (1, 1) NOT NULL,
    [FromCurrencyID] INT      NOT NULL,
    [ToCurrencyID]   INT      NOT NULL,
    [Value]          REAL     NOT NULL,
    [IsActive]       BIT      NOT NULL,
    [CreatedUserID]  INT      NOT NULL,
    [LastModUserID]  INT      NOT NULL,
    [CreatedDate]    DATETIME NOT NULL,
    [LastModDate]    DATETIME NOT NULL,
    [CompanyId]      INT      NOT NULL,
    [EffectFrom]     DATE     DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_dbo_CurrencyConversions] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

