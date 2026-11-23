CREATE TABLE [dbo].[POS_VoidInvoiceDetail] (
    [InvDetailID]        BIGINT          NOT NULL,
    [InvHeaderID]        BIGINT          NOT NULL,
    [CompanyID]          TINYINT         CONSTRAINT [DF_POS_VoidInvoiceDetail_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]          VARCHAR (20)    NOT NULL,
    [BusinessDate]       DATE            CONSTRAINT [DF_POS_VoidInvoiceDetail_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [LocationID]         INT             CONSTRAINT [DF_POS_VoidInvoiceDetail_LocationID] DEFAULT ((0)) NOT NULL,
    [InsertDateTime]     DATETIME        NOT NULL,
    [ItemID]             INT             CONSTRAINT [DF_POS_VoidInvoiceDetail_ItemID] DEFAULT ((0)) NOT NULL,
    [ItemCode]           VARCHAR (20)    CONSTRAINT [DF_POS_VoidInvoiceDetail_ItemCode] DEFAULT ('') NOT NULL,
    [AveragePrice]       NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceDetail_AveragePrice] DEFAULT ((0)) NOT NULL,
    [SellingPrice]       NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceDetail_SellingPrice] DEFAULT ((0)) NOT NULL,
    [Quantity]           NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceDetail_Quantity] DEFAULT ((0)) NOT NULL,
    [DiscountValue]      NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceDetail_DiscountValue] DEFAULT ((0)) NOT NULL,
    [DiscountPercentage] NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceDetail_DiscountPercentage] DEFAULT ((0)) NOT NULL,
    [ItemLineNo]         INT             CONSTRAINT [DF_POS_VoidInvoiceDetail_ItemLineNo] DEFAULT ((0)) NOT NULL
);


GO

