CREATE TABLE [dbo].[POS_SpecialOrderPayment] (
    [ID]             BIGINT          NOT NULL,
    [BillHeaderID]   BIGINT          CONSTRAINT [DF_POS_SpecialOrderPaymetn_BillHeaderID] DEFAULT ((0)) NOT NULL,
    [OrderNo]        VARCHAR (20)    CONSTRAINT [DF_POS_SpecialOrderPaymetn_OrderNo] DEFAULT ('') NOT NULL,
    [OrderDate]      DATETIME        CONSTRAINT [DF_POS_SpecialOrderPaymetn_SysDate1] DEFAULT (getdate()) NOT NULL,
    [OrderAmount]    NUMERIC (18, 2) CONSTRAINT [DF_POS_SpecialOrderPaymetn_PayAmount1] DEFAULT ((0)) NOT NULL,
    [PayCode]        VARCHAR (3)     CONSTRAINT [DF_POS_SpecialOrderPaymetn_PayCode] DEFAULT ('') NOT NULL,
    [PayAmount]      NUMERIC (18, 2) CONSTRAINT [DF_POS_SpecialOrderPaymetn_PayAmount] DEFAULT ((0)) NOT NULL,
    [UserName]       VARCHAR (20)    CONSTRAINT [DF_POS_SpecialOrderPaymetn_UserName] DEFAULT ('') NOT NULL,
    [Remarks]        VARCHAR (250)   CONSTRAINT [DF_POS_SpecialOrderPaymetn_Remarks] DEFAULT ('') NOT NULL,
    [OutletCode]     VARCHAR (5)     CONSTRAINT [DF_POS_SpecialOrderPaymetn_OutletCode] DEFAULT ('') NOT NULL,
    [SettlementType] VARCHAR (1)     CONSTRAINT [DF_POS_SpecialOrderPaymetn_SettlementType] DEFAULT ('') NOT NULL,
    [ReceiptNo]      VARCHAR (10)    CONSTRAINT [DF_POS_SpecialOrderPaymetn_ReceiptNo] DEFAULT ('') NOT NULL,
    [SysDate]        DATETIME        CONSTRAINT [DF_POS_SpecialOrderPaymetn_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsAdvance]      BIT             CONSTRAINT [DF_POS_SpecialOrderPayment_IsAdvance] DEFAULT ((0)) NOT NULL,
    [ShiftID]        BIGINT          CONSTRAINT [DF_POS_SpecialOrderPayment_ShiftID] DEFAULT ((0)) NOT NULL,
    [TenderedAmount] NUMERIC (18, 2) CONSTRAINT [DF_POS_SpecialOrderPayment_Tendered] DEFAULT ((0)) NOT NULL
);


GO

