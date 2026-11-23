CREATE TABLE [dbo].[POS_GiftVoucherPayTrans] (
    [DocNo]      VARCHAR (10)    NOT NULL,
    [DocDate]    DATETIME        CONSTRAINT [DF_GiftVoucherPayTrans_DocDate] DEFAULT (getdate()) NOT NULL,
    [PayCode]    VARCHAR (5)     NOT NULL,
    [Outlet]     VARCHAR (50)    CONSTRAINT [DF_GiftVoucherPayTrans_Outlet] DEFAULT ('L1') NOT NULL,
    [ShiftID]    BIGINT          CONSTRAINT [DF_GiftVoucherPayTrans_ShiftID] DEFAULT ((0)) NOT NULL,
    [Total]      NUMERIC (18, 8) CONSTRAINT [DF_GiftVoucherPayTrans_Total] DEFAULT ((0)) NOT NULL,
    [Tendered]   NUMERIC (18, 8) CONSTRAINT [DF_GiftVoucherPayTrans_Tendered] DEFAULT ((0)) NOT NULL,
    [ActualAmt]  NUMERIC (18, 8) CONSTRAINT [DF_GiftVoucherPayTrans_ActualAmt] DEFAULT ((0)) NOT NULL,
    [Remark]     VARCHAR (100)   CONSTRAINT [DF_GiftVoucherPayTrans_Remark] DEFAULT (' ') NOT NULL,
    [UserID]     VARCHAR (20)    CONSTRAINT [DF_GiftVoucherPayTrans_UserID] DEFAULT (' ') NOT NULL,
    [SysDate]    DATETIME        NOT NULL,
    [PropertyId] INT             NOT NULL,
    CONSTRAINT [PK_GiftVoucherPayTrans] PRIMARY KEY CLUSTERED ([DocNo] ASC, [PayCode] ASC, [Outlet] ASC)
);


GO

