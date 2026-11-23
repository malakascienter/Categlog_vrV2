CREATE TABLE [dbo].[StockItemWiseClassificationDetails] (
    [Id]                         INT            IDENTITY (1, 1) NOT NULL,
    [CompanyId]                  INT            NOT NULL,
    [LocationId]                 INT            NOT NULL,
    [StockItemHeaderID]          BIGINT         NOT NULL,
    [ItemClassificationHeaderID] INT            NOT NULL,
    [ItemClassificationDetailID] INT            NOT NULL,
    [IsActive]                   BIT            NOT NULL,
    [IPAddress]                  NVARCHAR (MAX) NULL,
    [CreatedUserID]              INT            NOT NULL,
    [LastModUserID]              INT            NOT NULL,
    [CreatedDate]                DATETIME       NOT NULL,
    [LastModDate]                DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.StockItemWiseClassificationDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

