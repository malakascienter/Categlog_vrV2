CREATE TABLE [dbo].[CurrencyMasters] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [Symbol]            NVARCHAR (MAX)  NULL,
    [Name]              NVARCHAR (MAX)  NULL,
    [ExchangeRate]      DECIMAL (18, 2) NOT NULL,
    [IsActive]          BIT             NOT NULL,
    [IPAddress]         NVARCHAR (MAX)  NULL,
    [CreatedUserID]     INT             NOT NULL,
    [LastModUserID]     INT             NOT NULL,
    [CreatedDate]       DATETIME        NOT NULL,
    [LastModDate]       DATETIME        NOT NULL,
    [ISOCode]           NVARCHAR (5)    NULL,
    [IsAllowSignOn]     BIT             DEFAULT ((0)) NOT NULL,
    [IsAllowSettlement] BIT             DEFAULT ((0)) NOT NULL,
    [IsAllowBalance]    BIT             DEFAULT ((0)) NOT NULL,
    [SortOrder]         INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.CurrencyMasters] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

