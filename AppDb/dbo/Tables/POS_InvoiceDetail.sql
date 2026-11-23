CREATE TABLE [dbo].[POS_InvoiceDetail] (
    [InvDetailID]        BIGINT          IDENTITY (1, 1) NOT NULL,
    [InvHeaderID]        BIGINT          NOT NULL,
    [CompanyID]          TINYINT         CONSTRAINT [DF_POS_InvoiceDetail_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]          VARCHAR (20)    NOT NULL,
    [BusinessDate]       DATE            CONSTRAINT [DF_POS_InvoiceDetail_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [LocationID]         INT             CONSTRAINT [DF_POS_InvoiceDetail_LocationID] DEFAULT ((0)) NOT NULL,
    [InsertDateTime]     DATETIME        NOT NULL,
    [ItemID]             INT             CONSTRAINT [DF_POS_InvoiceDetail_ItemID] DEFAULT ((0)) NOT NULL,
    [ItemCode]           VARCHAR (20)    CONSTRAINT [DF_POS_InvoiceDetail_ItemCode] DEFAULT ('') NOT NULL,
    [AveragePrice]       NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceDetail_AveragePrice] DEFAULT ((0)) NOT NULL,
    [SellingPrice]       NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceDetail_SellingPrice] DEFAULT ((0)) NOT NULL,
    [Quantity]           NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceDetail_Quantity] DEFAULT ((0)) NOT NULL,
    [DiscountValue]      NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceDetail_DiscountValue] DEFAULT ((0)) NOT NULL,
    [DiscountPercentage] NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceDetail_DiscountPercentage] DEFAULT ((0)) NOT NULL,
    [ItemLineNo]         INT             CONSTRAINT [DF_Table_1_LineNo] DEFAULT ((0)) NOT NULL,
    [NetAmount]          AS              (([Quantity]*[SellingPrice]-(([Quantity]*[SellingPrice])*[DiscountPercentage])/(100))-[DiscountValue]),
    [ReturnQuantity]     NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceDetail_ReturnQuantity_1] DEFAULT ((0)) NOT NULL,
    [DiscountCode]       VARCHAR (20)    CONSTRAINT [DF_POS_InvoiceDetail_DiscountCode] DEFAULT ('') NULL,
    [BatchNo]            VARCHAR (200)   CONSTRAINT [DF_POS_InvoiceDetail_BatchNo] DEFAULT ('''') NULL,
    [ExpiryDate]         DATETIME        CONSTRAINT [DF_POS_InvoiceDetail_ExpiryDate] DEFAULT (getdate()) NULL
);


GO

