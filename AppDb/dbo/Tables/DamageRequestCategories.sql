CREATE TABLE [dbo].[DamageRequestCategories] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [IsActive]      BIT            NOT NULL,
    [CompanyId]     INT            CONSTRAINT [DF_DamageRequestCategories_CompanyId] DEFAULT ((0)) NOT NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL
);


GO

