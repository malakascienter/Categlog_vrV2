CREATE TABLE [dbo].[POS_GiftVoucherTrans] (
    [DocNo]           VARCHAR (10) NOT NULL,
    [DocDate]         DATETIME     CONSTRAINT [DF_GiftVoucherTrans_DocDate] DEFAULT (getdate()) NOT NULL,
    [Outlet]          VARCHAR (5)  NOT NULL,
    [GiftVoucherCode] VARCHAR (10) NOT NULL,
    [VoucherNo]       BIGINT       CONSTRAINT [DF_GiftVoucherTrans_VoucherNo] DEFAULT ((0)) NOT NULL,
    [Quantity]        INT          CONSTRAINT [DF_GiftVoucherTrans_Quantity] DEFAULT ((0)) NOT NULL,
    [UnitValue]       NUMERIC (18) CONSTRAINT [DF_GiftVoucherTrans_UnitValue] DEFAULT ((0)) NOT NULL,
    [SysDate]         DATETIME     CONSTRAINT [DF_GiftVoucherTran_SysDate] DEFAULT (getdate()) NOT NULL,
    [UserID]          VARCHAR (20) CONSTRAINT [DF_GiftVoucherTrans_UserID] DEFAULT ('') NOT NULL,
    [PropertyId]      INT          NOT NULL,
    CONSTRAINT [PK_GiftVoucherTrans] PRIMARY KEY CLUSTERED ([DocNo] ASC, [GiftVoucherCode] ASC, [Outlet] ASC, [VoucherNo] ASC)
);


GO

