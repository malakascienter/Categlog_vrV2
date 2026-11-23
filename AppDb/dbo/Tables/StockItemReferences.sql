CREATE TABLE [dbo].[StockItemReferences] (
    [Id]                     INT            IDENTITY (1, 1) NOT NULL,
    [StockItemReferenceCode] NVARCHAR (MAX) NULL,
    [StockItemReferenceName] NVARCHAR (MAX) NULL,
    [IsActive]               BIT            NOT NULL,
    [IPAddress]              NVARCHAR (MAX) NULL,
    [CreatedUserID]          INT            NOT NULL,
    [LastModUserID]          INT            NOT NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [LastModDate]            DATETIME       NOT NULL,
    CONSTRAINT [PK_dbo.StockItemReferences] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

