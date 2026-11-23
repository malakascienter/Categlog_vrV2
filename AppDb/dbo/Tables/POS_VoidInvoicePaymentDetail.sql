CREATE TABLE [dbo].[POS_VoidInvoicePaymentDetail] (
    [InvPayDetailID] BIGINT          NOT NULL,
    [InvHeaderID]    BIGINT          NOT NULL,
    [CompanyID]      TINYINT         CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]      VARCHAR (20)    NOT NULL,
    [BusinessDate]   DATE            CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [LocationID]     INT             CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_LocationID] DEFAULT ((0)) NOT NULL,
    [InsertDateTime] DATETIME        NOT NULL,
    [UserID]         INT             CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_UserID] DEFAULT ((0)) NOT NULL,
    [ShiftNo]        BIGINT          CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_ShiftNo] DEFAULT ((0)) NOT NULL,
    [StationID]      TINYINT         NOT NULL,
    [PayType]        VARCHAR (1)     CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_PayType] DEFAULT ('') NOT NULL,
    [PayCode]        VARCHAR (3)     CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_PayCode] DEFAULT ('') NOT NULL,
    [CurrencyCode]   VARCHAR (3)     CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_CurrencyCode] DEFAULT ('') NOT NULL,
    [ConversionRate] NUMERIC (18, 4) CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_ConversionRate] DEFAULT ((0)) NOT NULL,
    [CurrencyAmount] NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_CurrencyAmount] DEFAULT ((0)) NOT NULL,
    [ActualAmount]   NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoicePaymentDetail_ActualAmount] DEFAULT ((0)) NOT NULL
);


GO

