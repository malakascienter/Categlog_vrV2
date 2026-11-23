CREATE TABLE [dbo].[BrokerMasters] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [AddLine1]      NVARCHAR (MAX) NULL,
    [AddLine2]      NVARCHAR (MAX) NULL,
    [AddLine3]      NVARCHAR (MAX) NULL,
    [Tele1]         NVARCHAR (MAX) NULL,
    [Email1]        NVARCHAR (MAX) NULL,
    [Tele2]         NVARCHAR (MAX) NULL,
    [Email2]        NVARCHAR (MAX) NULL,
    [Tele3]         NVARCHAR (MAX) NULL,
    [Fax]           NVARCHAR (MAX) NULL,
    [CurrencyID]    INT            NOT NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [CompanyId]     INT            DEFAULT ((0)) NOT NULL,
    [LocationId]    INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.BrokerMasters] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

