CREATE TABLE [dbo].[Categories] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [DepartmentId]         INT            NOT NULL,
    [Code]                 NVARCHAR (MAX) NULL,
    [Name]                 NVARCHAR (MAX) NULL,
    [PurchaseAccountID]    NVARCHAR (MAX) NULL,
    [CostOfSalesAccountID] NVARCHAR (MAX) NULL,
    [IsActive]             BIT            NOT NULL,
    [IPAddress]            NVARCHAR (MAX) NULL,
    [CreatedUserID]        INT            NOT NULL,
    [LastModUserID]        INT            NOT NULL,
    [CreatedDate]          DATETIME       NOT NULL,
    [LastModDate]          DATETIME       NOT NULL,
    [CompanyId]            INT            DEFAULT ((0)) NOT NULL,
    [PrefixLength]         INT            DEFAULT ((0)) NOT NULL,
    [Prefix]               NVARCHAR (MAX) NULL,
    [SerialLength]         INT            DEFAULT ((0)) NOT NULL,
    [Serial]               INT            DEFAULT ((0)) NOT NULL,
    [SuffixLength]         INT            DEFAULT ((0)) NOT NULL,
    [Suffix]               NVARCHAR (MAX) NULL,
    [CodeLength]           INT            DEFAULT ((0)) NOT NULL,
    [IsRetail]             BIT            CONSTRAINT [DF_Categories_IsRetail] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.Categories] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

