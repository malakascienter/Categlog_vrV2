CREATE TABLE [dbo].[POS_OrderReturnHeader] (
    [ReturnHeaderID]  BIGINT          IDENTITY (1, 1) NOT NULL,
    [PropertyId]      TINYINT         CONSTRAINT [DF_Table_1_CompanyID] DEFAULT ((0)) NOT NULL,
    [ReturnNo]        VARCHAR (20)    NOT NULL,
    [BusinessDate]    DATE            CONSTRAINT [DF_POS_OrderReturnHeader_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [InsertDateTime]  DATETIME        CONSTRAINT [DF_POS_OrderReturnHeader_InsertDateTime] DEFAULT (getdate()) NOT NULL,
    [UserID]          VARCHAR (20)    CONSTRAINT [DF_POS_OrderReturnHeader_UserID] DEFAULT ('') NOT NULL,
    [ShiftNo]         BIGINT          CONSTRAINT [DF_POS_OrderReturnHeader_ShiftNo] DEFAULT ((0)) NOT NULL,
    [Station]         VARCHAR (100)   CONSTRAINT [DF_POS_OrderReturnHeader_Station] DEFAULT ('') NOT NULL,
    [Outlet]          VARCHAR (5)     CONSTRAINT [DF_Table_1_LocationID] DEFAULT ('') NOT NULL,
    [ReturnAmount]    NUMERIC (18, 8) CONSTRAINT [DF_POS_OrderReturnHeader_ReturnAmount] DEFAULT ((0)) NOT NULL,
    [ReturnReason]    VARCHAR (250)   CONSTRAINT [DF_POS_OrderReturnHeader_ReturnReason] DEFAULT ('') NOT NULL,
    [OrderNo]         VARCHAR (20)    CONSTRAINT [DF_POS_OrderReturnHeader_OrderNo] DEFAULT ('') NOT NULL,
    [OrderDate]       DATE            CONSTRAINT [DF_Table_1_InvoiceDate] DEFAULT (getdate()) NOT NULL,
    [OrderOutlet]     VARCHAR (5)     CONSTRAINT [DF_Table_1_InvoiceLocationID] DEFAULT ('') NOT NULL,
    [OrderSysdate]    DATETIME        CONSTRAINT [DF_Table_1_InvoiceSysdate] DEFAULT (getdate()) NOT NULL,
    [RedeemOrderNo]   VARCHAR (20)    CONSTRAINT [DF_Table_1_RedeemInvoiceNo] DEFAULT ('') NOT NULL,
    [RedeemOrderDate] DATE            CONSTRAINT [DF_Table_1_RedeemInvoiceDate] DEFAULT (getdate()) NOT NULL,
    [RedeemOutlet]    VARCHAR (5)     CONSTRAINT [DF_Table_1_RedeemInvLocationID] DEFAULT ('') NOT NULL,
    [RedeemUserID]    VARCHAR (20)    CONSTRAINT [DF_POS_OrderReturnHeader_RedeemUserID] DEFAULT ('') NOT NULL,
    [RedeemSysdate]   DATETIME        CONSTRAINT [DF_Table_1_RedeemInvSysdate] DEFAULT (getdate()) NOT NULL
);


GO

