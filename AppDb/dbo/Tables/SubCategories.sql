CREATE TABLE [dbo].[SubCategories] (
    [Id]                     INT            IDENTITY (1, 1) NOT NULL,
    [CategoryId]             INT            NOT NULL,
    [Code]                   NVARCHAR (MAX) NULL,
    [Name]                   NVARCHAR (MAX) NULL,
    [IsActive]               BIT            NOT NULL,
    [IPAddress]              NVARCHAR (MAX) NULL,
    [CreatedUserID]          INT            NOT NULL,
    [LastModUserID]          INT            NOT NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [LastModDate]            DATETIME       NOT NULL,
    [CompanyId]              INT            CONSTRAINT [DF__SubCatego__Compa__36870511] DEFAULT ((0)) NOT NULL,
    [IsExpiryDateApplicable] BIT            CONSTRAINT [DF_SubCategories_IsExpiryDateApplicable] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.SubCategories] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_SubCategories_SubCategories] FOREIGN KEY ([Id]) REFERENCES [dbo].[SubCategories] ([Id])
);


GO

