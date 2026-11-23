CREATE TABLE [dbo].[POS_VoidInvoicePayment] (
    [InvPaymentID]   BIGINT          NOT NULL,
    [InvHeaderID]    BIGINT          NOT NULL,
    [CompanyID]      TINYINT         CONSTRAINT [DF_POS_VoidInvoicePayment_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]      VARCHAR (20)    NOT NULL,
    [BusinessDate]   DATE            CONSTRAINT [DF_POS_VoidInvoicePayment_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [LocationID]     INT             CONSTRAINT [DF_POS_VoidInvoicePayment_LocationID] DEFAULT ((0)) NOT NULL,
    [InsertDateTime] DATETIME        NOT NULL,
    [UserID]         INT             CONSTRAINT [DF_POS_VoidInvoicePayment_UserID] DEFAULT ((0)) NOT NULL,
    [ShiftNo]        BIGINT          CONSTRAINT [DF_POS_VoidInvoicePayment_ShiftNo] DEFAULT ((0)) NOT NULL,
    [StationID]      TINYINT         NOT NULL,
    [PayCode]        VARCHAR (3)     CONSTRAINT [DF_POS_VoidInvoicePayment_PayCode] DEFAULT ('') NOT NULL,
    [NetAmount]      NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoicePayment_NetAmount] DEFAULT ((0)) NOT NULL,
    [TenderedAmount] NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoicePayment_TenderedAmount] DEFAULT ((0)) NOT NULL,
    [ActualAmount]   NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoicePayment_ActualAmount] DEFAULT ((0)) NOT NULL,
    [PaymentRemark]  VARCHAR (50)    CONSTRAINT [DF_POS_VoidInvoicePayment_PaymentRemark] DEFAULT ('') NOT NULL
);


GO

