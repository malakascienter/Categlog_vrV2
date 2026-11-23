CREATE TABLE [dbo].[Customers] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [CustomerName]    NVARCHAR (MAX)  NULL,
    [AddLine1]        NVARCHAR (MAX)  NULL,
    [AddLine2]        NVARCHAR (MAX)  NULL,
    [AddLine3]        NVARCHAR (MAX)  NULL,
    [ContactPerson01] NVARCHAR (MAX)  NULL,
    [Tele1]           NVARCHAR (MAX)  NULL,
    [Email1]          NVARCHAR (MAX)  NULL,
    [ContactPerson02] NVARCHAR (MAX)  NULL,
    [Tele2]           NVARCHAR (MAX)  NULL,
    [Email2]          NVARCHAR (MAX)  NULL,
    [ContactPerson03] NVARCHAR (MAX)  NULL,
    [Tele3]           NVARCHAR (MAX)  NULL,
    [Email3]          NVARCHAR (MAX)  NULL,
    [Fax]             NVARCHAR (MAX)  NULL,
    [CurrencyID]      INT             NOT NULL,
    [IsActive]        BIT             NOT NULL,
    [IPAddress]       NVARCHAR (MAX)  NULL,
    [CreatedUserID]   INT             NOT NULL,
    [LastModUserID]   INT             NOT NULL,
    [CreatedDate]     DATETIME        NOT NULL,
    [LastModDate]     DATETIME        NOT NULL,
    [CompanyId]       INT             DEFAULT ((0)) NOT NULL,
    [LocationId]      INT             DEFAULT ((0)) NOT NULL,
    [Code]            NVARCHAR (MAX)  NULL,
    [IsVat]           BIT             DEFAULT ((0)) NOT NULL,
    [VatNumber]       NVARCHAR (MAX)  NULL,
    [CreditLimit]     DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.Customers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

