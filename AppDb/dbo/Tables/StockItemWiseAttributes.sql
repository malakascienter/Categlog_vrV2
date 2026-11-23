CREATE TABLE [dbo].[StockItemWiseAttributes] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [CompanyId]            INT            NOT NULL,
    [LocationId]           INT            NOT NULL,
    [StockItemHeaderID]    BIGINT         NOT NULL,
    [StockItemAttributeID] INT            NOT NULL,
    [Remarks]              NVARCHAR (MAX) NULL,
    [IsActive]             BIT            NOT NULL,
    [CreatedUserID]        INT            NOT NULL,
    [LastModUserID]        INT            NOT NULL,
    [CreatedDate]          DATETIME       NOT NULL,
    [LastModDate]          DATETIME       NOT NULL,
    [IPAddress]            NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_dbo.StockItemWiseAttributes] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [StockItemWiseAttributes_StockItemHeaderID]
    ON [dbo].[StockItemWiseAttributes]([StockItemAttributeID] ASC, [IsActive] ASC)
    INCLUDE([StockItemHeaderID]);


GO

