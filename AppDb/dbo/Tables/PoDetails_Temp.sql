CREATE TABLE [dbo].[PoDetails_Temp] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [PoHeaderID]         INT             NOT NULL,
    [PoDetailID]         INT             NOT NULL,
    [StockItemID]        INT             NOT NULL,
    [UnitID]             INT             NOT NULL,
    [UnitPrice]          DECIMAL (18, 2) NOT NULL,
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
    [TaxValue]           DECIMAL (18, 8) DEFAULT ((0)) NOT NULL,
    [TBPHeaderId]        INT             DEFAULT ((0)) NOT NULL,
    [StockName]          VARCHAR (50)    NULL,
    [UnitName]           VARCHAR (50)    NULL,
    [CurrentStock]       DECIMAL (18, 8) NULL,
    [ItemTotal]          DECIMAL (18)    NULL,
    CONSTRAINT [PK_dbo.PoDetails_Temp] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

