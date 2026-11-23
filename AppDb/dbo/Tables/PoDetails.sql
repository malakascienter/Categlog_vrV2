CREATE TABLE [dbo].[PoDetails] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PoHeaderID]         INT             NOT NULL,
    [PoDetailID]         INT             NOT NULL,
    [StockItemID]        INT             NOT NULL,
    [UnitID]             INT             NOT NULL,
    [UnitPrice]          DECIMAL (18, 6) NOT NULL,
    [RequestedQuantity]  FLOAT (53)      NOT NULL,
    [ApprovedQuantity]   FLOAT (53)      NOT NULL,
    [ReceivedQuantity]   FLOAT (53)      NOT NULL,
    [Remarks]            NVARCHAR (1000) NULL,
    [DiscountValue]      FLOAT (53)      NOT NULL,
    [DiscountPercentage] FLOAT (53)      NOT NULL,
    [IPAddress]          NVARCHAR (MAX)  NULL,
    [CreatedUserID]      INT             NOT NULL,
    [LastModUserID]      INT             NOT NULL,
    [CreatedDate]        DATETIME        NOT NULL,
    [LastModDate]        DATETIME        NOT NULL,
    [TaxValue]           DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [TBPHeaderId]        INT             DEFAULT ((0)) NOT NULL,
    [ProcurementID]      INT             NULL,
    CONSTRAINT [PK_dbo.PoDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [PoDetails_PoHeaderID]
    ON [dbo].[PoDetails]([PoHeaderID] ASC);


GO

