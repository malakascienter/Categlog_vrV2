CREATE TABLE [dbo].[StockItemDetails] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]           INT             NOT NULL,
    [CompanyID]            INT             NOT NULL,
    [LocationID]           INT             NOT NULL,
    [StockItemHeaderID]    INT             NOT NULL,
    [MasterUnitID]         INT             NOT NULL,
    [PurchasingUnitID]     INT             NOT NULL,
    [MinimumQuantity]      DECIMAL (18, 6) NOT NULL,
    [MaximumQuantity]      DECIMAL (18, 6) NOT NULL,
    [ReOrderLevel]         DECIMAL (18, 6) NOT NULL,
    [ReOrderQuantity]      DECIMAL (18, 6) NOT NULL,
    [ReOrderPeriod]        DECIMAL (18, 6) NOT NULL,
    [PurchaseAccountID]    NVARCHAR (MAX)  NULL,
    [CostOfSalesAccountID] NVARCHAR (MAX)  NULL,
    [AveragePrice]         DECIMAL (18, 6) NOT NULL,
    [SellingPrice]         DECIMAL (18, 6) NOT NULL,
    [WholesalePrice]       DECIMAL (18, 6) NOT NULL,
    [IsActive]             BIT             NOT NULL,
    [ReportingUnitID]      INT             NOT NULL,
    [QuantityInHand]       DECIMAL (18, 6) NOT NULL,
    [StockItemId]          INT             NOT NULL,
    [IPAddress]            NVARCHAR (MAX)  NULL,
    [CreatedUserID]        INT             NOT NULL,
    [LastModUserID]        INT             NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [LastModDate]          DATETIME        NOT NULL,
    [BatchNo]              NVARCHAR (MAX)  NULL,
    [ProfitMargin]         DECIMAL (18, 6) CONSTRAINT [DF__StockItem__Profi__5398450B] DEFAULT ((0)) NOT NULL,
    [ItemAge]              DECIMAL (18, 6) CONSTRAINT [DF_StockItemDetails_ItemAge] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.StockItemDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_StockItemHeaderID_QuantityInHand]
    ON [dbo].[StockItemDetails]([PropertyID] ASC, [LocationID] ASC, [IsActive] ASC)
    INCLUDE([StockItemHeaderID], [AveragePrice], [QuantityInHand]);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_LocationID]
    ON [dbo].[StockItemDetails]([LocationID] ASC, [StockItemId] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_Items_3]
    ON [dbo].[StockItemDetails]([LocationID] ASC, [StockItemHeaderID] ASC);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_StockItemHeaderID_MasterUnitID_AveragePrice_SellingPrice_QuantityInHand]
    ON [dbo].[StockItemDetails]([PropertyID] ASC, [LocationID] ASC, [IsActive] ASC)
    INCLUDE([StockItemHeaderID], [MasterUnitID], [AveragePrice], [SellingPrice], [QuantityInHand]);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_StockItemHeaderID_MasterUnitID]
    ON [dbo].[StockItemDetails]([StockItemHeaderID] ASC)
    INCLUDE([PropertyID], [LocationID], [MasterUnitID]);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_ReOrderLevel_LocationID]
    ON [dbo].[StockItemDetails]([ReOrderLevel] ASC)
    INCLUDE([LocationID], [StockItemHeaderID], [MasterUnitID], [ReOrderQuantity], [QuantityInHand]);


GO

CREATE NONCLUSTERED INDEX [stockdetails]
    ON [dbo].[StockItemDetails]([PropertyID] ASC, [LocationID] ASC)
    INCLUDE([StockItemHeaderID], [MasterUnitID], [AveragePrice], [SellingPrice]);


GO

CREATE NONCLUSTERED INDEX [IX_Items]
    ON [dbo].[StockItemDetails]([IsActive] ASC)
    INCLUDE([PropertyID], [LocationID], [StockItemHeaderID], [MasterUnitID], [QuantityInHand]);


GO

CREATE NONCLUSTERED INDEX [IX_StockItemDetails_Location_Header_Unit]
    ON [dbo].[StockItemDetails]([LocationID] ASC, [StockItemHeaderID] ASC)
    INCLUDE([MasterUnitID]);


GO

CREATE NONCLUSTERED INDEX [IDX_StockItemDetails_StockItemHeaderID_PropertyId_LocationID]
    ON [dbo].[StockItemDetails]([StockItemHeaderID] ASC, [PropertyID] ASC, [LocationID] ASC)
    INCLUDE([QuantityInHand], [MasterUnitID], [IsActive], [LastModDate]);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_StockItemHeaderID]
    ON [dbo].[StockItemDetails]([PropertyID] ASC, [LocationID] ASC, [IsActive] ASC)
    INCLUDE([StockItemHeaderID], [MasterUnitID], [QuantityInHand], [LastModDate]);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_ReOrderLevel]
    ON [dbo].[StockItemDetails]([ReOrderLevel] ASC)
    INCLUDE([LocationID], [StockItemHeaderID], [MasterUnitID], [ReOrderQuantity], [QuantityInHand]);


GO

CREATE NONCLUSTERED INDEX [IX_Location]
    ON [dbo].[StockItemDetails]([IsActive] ASC, [LocationID] ASC)
    INCLUDE([PropertyID], [StockItemHeaderID], [MasterUnitID], [QuantityInHand]);


GO

CREATE NONCLUSTERED INDEX [<Name of Missing Index, sysname,>]
    ON [dbo].[StockItemDetails]([PropertyID] ASC, [LocationID] ASC)
    INCLUDE([StockItemHeaderID], [MasterUnitID], [AveragePrice]);


GO

CREATE NONCLUSTERED INDEX [StockItemDetails_1]
    ON [dbo].[StockItemDetails]([PropertyID] ASC, [IsActive] ASC)
    INCLUDE([LocationID], [StockItemHeaderID], [AveragePrice]);


GO

CREATE NONCLUSTERED INDEX [IDX_StockItemDetails]
    ON [dbo].[StockItemDetails]([StockItemHeaderID] ASC, [LocationID] ASC, [PropertyID] ASC);


GO

