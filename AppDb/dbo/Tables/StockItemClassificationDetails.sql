CREATE TABLE [dbo].[StockItemClassificationDetails] (
    [Id]                         INT            IDENTITY (1, 1) NOT NULL,
    [ItemClassificationHeaderID] INT            NOT NULL,
    [CompanyId]                  INT            NOT NULL,
    [LocationId]                 INT            NOT NULL,
    [Code]                       NVARCHAR (MAX) NULL,
    [Name]                       NVARCHAR (MAX) NULL,
    [IsActive]                   BIT            NOT NULL,
    [IPAddress]                  NVARCHAR (MAX) NULL,
    [CreatedUserID]              INT            NOT NULL,
    [LastModUserID]              INT            NOT NULL,
    [CreatedDate]                DATETIME       NOT NULL,
    [LastModDate]                DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.StockItemClassificationDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

