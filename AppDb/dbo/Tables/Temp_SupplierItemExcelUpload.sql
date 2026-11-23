CREATE TABLE [dbo].[Temp_SupplierItemExcelUpload] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [StockItemCode]     VARCHAR (20)    NULL,
    [LocationName]      VARCHAR (100)   NULL,
    [ItemName]          VARCHAR (100)   NULL,
    [CostPrice]         DECIMAL (18, 2) NULL,
    [TaxName]           VARCHAR (50)    NULL,
    [IsDefaultSupplier] BIT             NULL,
    [TaxGroupId]        INT             NULL,
    [PurchaseUnitName]  VARCHAR (50)    NULL,
    [LocationCode]      VARCHAR (20)    NULL,
    [CategoryName]      VARCHAR (50)    NULL,
    [SubCategoryName]   VARCHAR (50)    NULL,
    [PropertyID]        INT             NULL,
    [SupplierID]        INT             NULL,
    [UserID]            INT             NULL,
    [LocationID]        INT             NULL,
    [CreatedDate]       DATETIME        CONSTRAINT [DF_Temp_SupplierItemExcelUpload_CreatedDate] DEFAULT (getdate()) NULL
);


GO

