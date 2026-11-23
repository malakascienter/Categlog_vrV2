CREATE TABLE [dbo].[ProjectWiseCurrencies] (
    [ID]            INT             IDENTITY (1, 1) NOT NULL,
    [ProjectID]     INT             NOT NULL,
    [Currency]      INT             NOT NULL,
    [BaseCurrency]  INT             NOT NULL,
    [ExchangeRate]  DECIMAL (18, 2) NOT NULL,
    [IPAddress]     NVARCHAR (MAX)  NULL,
    [CreatedUserID] INT             NOT NULL,
    [LastModUserID] INT             NOT NULL,
    [CreatedDate]   DATETIME        NOT NULL,
    [LastModDate]   DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.ProjectWiseCurrencies] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

