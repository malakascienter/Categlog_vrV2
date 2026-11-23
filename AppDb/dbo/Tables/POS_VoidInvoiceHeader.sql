CREATE TABLE [dbo].[POS_VoidInvoiceHeader] (
    [InvHeaderID]            BIGINT          NOT NULL,
    [CompanyID]              TINYINT         CONSTRAINT [DF_POS_VoidInvoiceHeader_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]              VARCHAR (20)    NOT NULL,
    [BusinessDate]           DATE            CONSTRAINT [DF_POS_VoidInvoiceHeader_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [InsertDateTime]         DATETIME        NOT NULL,
    [UserID]                 INT             CONSTRAINT [DF_POS_VoidInvoiceHeader_UserID] DEFAULT ((0)) NOT NULL,
    [ShiftNo]                BIGINT          CONSTRAINT [DF_POS_VoidInvoiceHeader_ShiftNo] DEFAULT ((0)) NOT NULL,
    [StationID]              TINYINT         NOT NULL,
    [LocationID]             INT             CONSTRAINT [DF_POS_VoidInvoiceHeader_LocationID] DEFAULT ((0)) NOT NULL,
    [SubAmount]              NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceHeader_SubAmount] DEFAULT ((0)) NOT NULL,
    [Discount]               NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceHeader_Discount] DEFAULT ((0)) NOT NULL,
    [ChargeAmount]           NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceHeader_ChargeAmount] DEFAULT ((0)) NOT NULL,
    [NetAmount]              NUMERIC (18, 8) CONSTRAINT [DF_POS_VoidInvoiceHeader_NetAmount] DEFAULT ((0)) NOT NULL,
    [AuthorizedUserID]       INT             CONSTRAINT [DF_POS_VoidInvoiceHeader_VoidUserID1] DEFAULT ((0)) NOT NULL,
    [VoidUserID]             INT             CONSTRAINT [DF_Table_1_UserID1] DEFAULT ((0)) NOT NULL,
    [VoidDateTime]           DATETIME        NOT NULL,
    [VoidReason]             VARCHAR (250)   CONSTRAINT [DF_POS_VoidInvoiceHeader_VoidReason] DEFAULT ('') NOT NULL,
    [GuideCompanyID]         INT             CONSTRAINT [DF_POS_VoidInvoiceHeader_GuideCompanyID] DEFAULT ((0)) NOT NULL,
    [GuideID]                INT             CONSTRAINT [DF_POS_VoidInvoiceHeader_GuideID] DEFAULT ((0)) NOT NULL,
    [GuideCompanyPercentage] NUMERIC (18, 2) CONSTRAINT [DF_POS_VoidInvoiceHeader_GuideCompanyPercentage] DEFAULT ((0)) NOT NULL,
    [GuidePercentage]        NUMERIC (18, 2) CONSTRAINT [DF_POS_VoidInvoiceHeader_GuidePercentage] DEFAULT ((0)) NOT NULL
);


GO

