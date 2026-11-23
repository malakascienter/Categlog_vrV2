CREATE TABLE [dbo].[temp_potemp] (
    [RequestHeaderID]        INT           NULL,
    [LocationID]             INT           NULL,
    [DocumentNo]             VARCHAR (50)  NULL,
    [RequestDate]            DATETIME      NULL,
    [HRemarks]               VARCHAR (500) NULL,
    [DepartmentID]           INT           NULL,
    [DepartmentName]         VARCHAR (200) NULL,
    [StockItemID]            INT           NULL,
    [ItemName]               VARCHAR (200) NULL,
    [StockItemCode]          VARCHAR (50)  NULL,
    [UnitID]                 INT           NULL,
    [UnitName]               VARCHAR (200) NULL,
    [ApprovedQuantity]       MONEY         NULL,
    [ItemRemarks]            VARCHAR (200) NULL,
    [RequestedQuantity]      MONEY         NULL,
    [SupplierPurchaseUnitID] INT           NULL,
    [Supplier]               VARCHAR (200) NULL,
    [CostPrice]              MONEY         NULL,
    [SupplierID]             INT           NULL,
    [LocationName]           VARCHAR (200) NULL
);


GO

