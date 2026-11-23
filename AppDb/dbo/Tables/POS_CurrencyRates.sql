CREATE TABLE [dbo].[POS_CurrencyRates] (
    [CurrCode]          VARCHAR (3)     CONSTRAINT [DF_CurrencyRates_CurrCode] DEFAULT ('') NOT NULL,
    [CurrName]          VARCHAR (20)    CONSTRAINT [DF_Table_2_CurrCode1] DEFAULT ('') NOT NULL,
    [ConversionRate]    NUMERIC (18, 4) CONSTRAINT [DF_CurrencyRates_ConversionRate] DEFAULT ((0)) NOT NULL,
    [AllowBalance]      BIT             CONSTRAINT [DF_CurrencyRates_AllowBalance] DEFAULT ((0)) NOT NULL,
    [AllowPayments]     BIT             CONSTRAINT [DF_CurrencyRates_AllowPayments] DEFAULT ((0)) NOT NULL,
    [AllowSignOn]       BIT             CONSTRAINT [DF_POS_CurrencyRates_AllowPayments1] DEFAULT ((0)) NOT NULL,
    [SortOrder]         SMALLINT        CONSTRAINT [DF_CurrencyRates_OrderSequence] DEFAULT ((0)) NOT NULL,
    [PropertyId]        INT             NOT NULL,
    [CreatedUserId]     INT             DEFAULT ((0)) NOT NULL,
    [CreatedDateTime]   DATETIME        DEFAULT (getdate()) NOT NULL,
    [ModifiedUserId]    INT             DEFAULT ((0)) NOT NULL,
    [ModifiedDateTime]  DATETIME        DEFAULT (getdate()) NOT NULL,
    [IsActive]          BIT             DEFAULT ((0)) NOT NULL,
    [IsUpload]          BIT             DEFAULT ((0)) NOT NULL,
    [Id]                BIGINT          IDENTITY (1, 1) NOT NULL,
    [EffectFrom]        DATE            DEFAULT (getdate()) NOT NULL,
    [IsBaseCurrency]    BIT             DEFAULT ((0)) NOT NULL,
    [BaseCurrencyId]    BIGINT          DEFAULT ((0)) NOT NULL,
    [NewConversionRate] DECIMAL (18, 6) DEFAULT ((0)) NOT NULL
);


GO

