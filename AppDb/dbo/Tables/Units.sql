CREATE TABLE [dbo].[Units] (
    [Id]            INT            IDENTITY (1, 1) NOT NULL,
    [LocationID]    INT            NOT NULL,
    [Code]          NVARCHAR (MAX) NULL,
    [Name]          NVARCHAR (MAX) NULL,
    [IsActive]      BIT            NOT NULL,
    [IPAddress]     NVARCHAR (MAX) NULL,
    [CreatedUserID] INT            NOT NULL,
    [LastModUserID] INT            NOT NULL,
    [CreatedDate]   DATETIME       NOT NULL,
    [LastModDate]   DATETIME       NOT NULL,
    [CompanyId]     INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.Units] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

