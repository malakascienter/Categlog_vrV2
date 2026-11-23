CREATE TABLE [dbo].[SupplierWiseItemDetails] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [CompanyId]            INT             NOT NULL,
    [LocationId]           INT             NOT NULL,
    [SupplierID]           INT             NOT NULL,
    [StockItemID]          BIGINT          NOT NULL,
    [PurchaseUnitID]       INT             NOT NULL,
    [CostPrice]            DECIMAL (18, 6) NOT NULL,
    [IsDefaultSupplier]    BIT             NOT NULL,
    [CreatedUserID]        INT             NOT NULL,
    [LastModUserID]        INT             NOT NULL,
    [CreatedDate]          DATETIME        NOT NULL,
    [LastModDate]          DATETIME        NOT NULL,
    [IPAddress]            NVARCHAR (MAX)  NULL,
    [TBPHeaderID]          INT             CONSTRAINT [DF__SupplierW__TBPHe__55808D7D] DEFAULT ((0)) NOT NULL,
    [TaxGroupID]           INT             NULL,
    [Validfrom]            DATE            NULL,
    [ValidTo]              DATE            NULL,
    [IsContractedSupplier] BIT             CONSTRAINT [DF_SupplierWiseItemDetails_IsContractedSupplier] DEFAULT ((0)) NULL,
    [IsQuotation]          BIT             CONSTRAINT [DF_SupplierWiseItemDetails_IsQuotation] DEFAULT ((0)) NOT NULL,
    [QuotationStatus]      CHAR (3)        CONSTRAINT [DF_SupplierWiseItemDetails_QuotationStatus] DEFAULT ('N') NOT NULL,
    CONSTRAINT [PK_dbo.SupplierWiseItemDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [SupplierWiseItemDetails_CompanyId_PurchaseUnitID_CostPrice]
    ON [dbo].[SupplierWiseItemDetails]([LocationId] ASC, [SupplierID] ASC, [StockItemID] ASC)
    INCLUDE([CompanyId], [PurchaseUnitID], [CostPrice], [IsDefaultSupplier], [CreatedUserID], [LastModUserID], [CreatedDate], [LastModDate], [IPAddress], [TBPHeaderID], [TaxGroupID], [Validfrom], [ValidTo]);


GO

CREATE NONCLUSTERED INDEX [SupplierWiseItemDetails_LocationId_StockItemID]
    ON [dbo].[SupplierWiseItemDetails]([LocationId] ASC, [StockItemID] ASC, [IsDefaultSupplier] ASC);


GO

CREATE NONCLUSTERED INDEX [SupplierWiseItemDetails_StockItemID_PurchaseUnitID_CostPrice_IsDefaultSupplier]
    ON [dbo].[SupplierWiseItemDetails]([LocationId] ASC, [SupplierID] ASC, [ValidTo] ASC)
    INCLUDE([StockItemID], [PurchaseUnitID], [CostPrice], [IsDefaultSupplier]);


GO

CREATE NONCLUSTERED INDEX [IX_SupplierWiseItemDetails_ContractedSupplier]
    ON [dbo].[SupplierWiseItemDetails]([CompanyId] ASC, [LocationId] ASC, [StockItemID] ASC, [IsContractedSupplier] ASC, [CostPrice] ASC)
    INCLUDE([SupplierID]);


GO

CREATE NONCLUSTERED INDEX [SupplierWiseItemDetails_StockItemID_CostPrice_IsDefaultSupplier]
    ON [dbo].[SupplierWiseItemDetails]([LocationId] ASC, [SupplierID] ASC, [ValidTo] ASC)
    INCLUDE([StockItemID], [CostPrice], [IsDefaultSupplier]);


GO

CREATE NONCLUSTERED INDEX [SupplierWiseItemDetails_SupplierID]
    ON [dbo].[SupplierWiseItemDetails]([SupplierID] ASC)
    INCLUDE([CompanyId], [StockItemID], [PurchaseUnitID], [CostPrice]);


GO

