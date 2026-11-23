CREATE TABLE [dbo].[POS_VoidInvoiceChargeDetail] (
    [InvChargeDetailID] BIGINT          NOT NULL,
    [InvHeaderID]       BIGINT          NOT NULL,
    [CompanyID]         TINYINT         CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]         VARCHAR (20)    NOT NULL,
    [BusinessDate]      DATE            CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [LocationID]        INT             CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_LocationID] DEFAULT ((0)) NOT NULL,
    [ItemID]            INT             CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_ItemID] DEFAULT ((0)) NOT NULL,
    [ItemCode]          VARCHAR (20)    CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_ItemCode] DEFAULT ('') NOT NULL,
    [ItemLineNo]        INT             CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_ItemLineNo] DEFAULT ((0)) NOT NULL,
    [ChargeHeaderID]    INT             NOT NULL,
    [ChargeTypeID]      INT             NOT NULL,
    [ActualPercentage]  NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_ActualPercentage] DEFAULT ((0)) NOT NULL,
    [ChargeAmount]      NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceChargeDetail_ChargeAmount] DEFAULT ((0)) NOT NULL
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sub Total Percentage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_VoidInvoiceChargeDetail', @level2type = N'COLUMN', @level2name = N'ActualPercentage';


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sub Total Percentage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_VoidInvoiceChargeDetail', @level2type = N'COLUMN', @level2name = N'ChargeAmount';


GO

