CREATE TABLE [dbo].[SupplierQuotationUploadDetail] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [QuotationDetailID]  INT             NULL,
    [PropertyID]         INT             NULL,
    [SupplierID]         INT             NULL,
    [ItemID]             INT             NULL,
    [Quantity]           DECIMAL (18, 4) NULL,
    [Price]              DECIMAL (18, 4) NULL,
    [QuotationHeaderID]  INT             NULL,
    [IsQuotationUpload]  BIT             CONSTRAINT [DF_SupplierQuotationUploadDetail_IsQuotationUpload] DEFAULT ((0)) NOT NULL,
    [Remark]             VARCHAR (MAX)   NULL,
    [TaxAmount]          DECIMAL (18, 4) CONSTRAINT [DF_SupplierQuotationUploadDetail_TaxAmount] DEFAULT ((0)) NOT NULL,
    [DiscountValue]      DECIMAL (18, 4) CONSTRAINT [DF_SupplierQuotationUploadDetail_DiscountValue] DEFAULT ((0)) NOT NULL,
    [DiscountPercentage] DECIMAL (18, 4) CONSTRAINT [DF_SupplierQuotationUploadDetail_DiscountPercentage] DEFAULT ((0)) NOT NULL,
    [NetPrice]           DECIMAL (18, 4) CONSTRAINT [DF_SupplierQuotationUploadDetail_NetPrice] DEFAULT ((0)) NOT NULL,
    [ChangeRemark]       NVARCHAR (500)  NULL
);


GO

