CREATE TABLE [dbo].[StockItemHeadersSigiriya] (
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
    [SubCategory2ID]         INT            NOT NULL,
    [IsPriceEditable]        BIT            NOT NULL,
    [MaintainPriceHistory]   BIT            NOT NULL,
    [Isbundle]               BIT            NOT NULL,
    [BrandedItem]            BIT            NULL,
    [GenericItemCode]        VARCHAR (MAX)  NULL,
    [StockItemHeaderID]      INT            NOT NULL,
    [UnitID]                 INT            NOT NULL
);


GO

