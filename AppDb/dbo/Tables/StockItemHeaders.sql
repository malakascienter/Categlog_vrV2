CREATE TABLE [dbo].[StockItemHeaders] (
    [Id]                     INT            IDENTITY (1, 1) NOT NULL,
    [CompanyId]              INT            NOT NULL,
    [LocationId]             INT            NOT NULL,
    [StockItemCode]          NVARCHAR (MAX) NULL,
    [PLUCode]                NVARCHAR (MAX) NULL,
    [ReferanceCode]          NVARCHAR (MAX) NULL,
    [Barcode]                NVARCHAR (MAX) NULL,
    [Name]                   NVARCHAR (MAX) NULL,
    [NameOnInvoice]          NVARCHAR (MAX) NULL,
    [ImageUrl]               NVARCHAR (MAX) NULL,
    [CategoryID]             INT            NOT NULL,
    [SubCategoryID]          INT            NOT NULL,
    [SupplierID]             INT            NOT NULL,
    [TaxGroupID]             INT            NOT NULL,
    [CostingMethod]          INT            NOT NULL,
    [Remarks]                NVARCHAR (MAX) NULL,
    [IsExpiryDateApplicable] BIT            NOT NULL,
    [IPAddress]              NVARCHAR (MAX) NULL,
    [CreatedUserID]          INT            NOT NULL,
    [LastModUserID]          INT            NOT NULL,
    [CreatedDate]            DATETIME       NOT NULL,
    [LastModDate]            DATETIME       NOT NULL,
    [SubCategory2ID]         INT            DEFAULT ((0)) NOT NULL,
    [IsPriceEditable]        BIT            DEFAULT ((0)) NOT NULL,
    [MaintainPriceHistory]   BIT            DEFAULT ((0)) NOT NULL,
    [Isbundle]               BIT            DEFAULT ((0)) NOT NULL,
    [BrandedItem]            BIT            NULL,
    [GenericItemCode]        VARCHAR (MAX)  CONSTRAINT [DF_StockItemHeaders_GenericItemCode] DEFAULT ((0)) NULL,
    [IsMultiplePrices]       BIT            CONSTRAINT [DF_StockItemHeaders_IsMultiplePrices] DEFAULT ((0)) NULL,
    [IsMultipleBarcode]      BIT            CONSTRAINT [DF_StockItemHeaders_IsMultipleBarcode] DEFAULT ((0)) NULL,
    [IsAllowDiscount]        BIT            CONSTRAINT [DF_StockItemHeaders_IsAllowDiscount] DEFAULT ((0)) NULL,
    [IsFractionItem]         BIT            CONSTRAINT [DF_StockItemHeaders_IsFractionItem] DEFAULT ((0)) NULL,
    [IsSerialNo]             BIT            CONSTRAINT [DF_StockItemHeaders_IsSerialNo] DEFAULT ((0)) NULL,
    [IsAllowReturnItem]      BIT            CONSTRAINT [DF_StockItemHeaders_IsAllowReturnItem] DEFAULT ((0)) NULL,
    [IsOpenPrice]            BIT            CONSTRAINT [DF_StockItemHeaders_IsOpenPrice] DEFAULT ((0)) NULL,
    [ChargeHeaderID]         INT            NULL,
    [IsSellingItem]          BIT            CONSTRAINT [DF_StockItemHeaders_IsSellingItem] DEFAULT ((0)) NULL,
    [ERPReferenceCode]       VARCHAR (200)  NULL,
    [IsProductionItem]       BIT            CONSTRAINT [DF_StockItemHeaders_IsProductionItem] DEFAULT ((0)) NULL,
    [ProductionLocationId]   INT            DEFAULT ((0)) NOT NULL,
    [DeliveryScheduleId]     INT            DEFAULT ((0)) NOT NULL,
    [ReportUnitID]           INT            NULL,
    CONSTRAINT [PK_dbo.StockItemHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [StockItemHeaders_Name]
    ON [dbo].[StockItemHeaders]([CompanyId] ASC)
    INCLUDE([Name]);


GO

CREATE NONCLUSTERED INDEX [StockItemHeaders_StockItemCode]
    ON [dbo].[StockItemHeaders]([CompanyId] ASC)
    INCLUDE([StockItemCode]);


GO

CREATE NONCLUSTERED INDEX [StockItemHeaders_StockItemCode_CompanyId]
    ON [dbo].[StockItemHeaders]([CompanyId] ASC)
    INCLUDE([StockItemCode]);


GO

CREATE NONCLUSTERED INDEX [StockItemHeaders_IsExpiryDateApplicable]
    ON [dbo].[StockItemHeaders]([CategoryID] ASC, [SubCategoryID] ASC)
    INCLUDE([IsExpiryDateApplicable], [SubCategory2ID]);


GO

CREATE NONCLUSTERED INDEX [IDX_StockItemHeaders_ID_CategoryID_SubCategoryID]
    ON [dbo].[StockItemHeaders]([Id] ASC, [CategoryID] ASC, [SubCategoryID] ASC);


GO

