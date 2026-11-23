CREATE TABLE [dbo].[POS_GiftVoucher] (
    [ID]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [BatchNo]         INT          DEFAULT ((0)) NOT NULL,
    [TypePrefix]      VARCHAR (2)  DEFAULT ('') NOT NULL,
    [VoucherMode]     VARCHAR (2)  DEFAULT ('') NOT NULL,
    [VoucherNo]       BIGINT       DEFAULT ((0)) NOT NULL,
    [Amount]          NUMERIC (18) DEFAULT ((0)) NOT NULL,
    [CreateUser]      VARCHAR (20) DEFAULT ('') NOT NULL,
    [CreateDate]      DATETIME     DEFAULT (getdate()) NOT NULL,
    [TransferNo]      INT          DEFAULT ((0)) NOT NULL,
    [TransferUser]    VARCHAR (20) DEFAULT ('') NOT NULL,
    [TransferDate]    DATETIME     DEFAULT (getdate()) NOT NULL,
    [TransferOutlet]  VARCHAR (3)  DEFAULT ('') NOT NULL,
    [SaleDate]        DATETIME     DEFAULT (getdate()) NOT NULL,
    [SaleOrderNo]     VARCHAR (6)  DEFAULT ('') NOT NULL,
    [SaleOutlet]      VARCHAR (3)  DEFAULT ('') NOT NULL,
    [RedeemDate]      DATETIME     DEFAULT (getdate()) NOT NULL,
    [RedeemOrderNo]   VARCHAR (6)  DEFAULT ('') NOT NULL,
    [RedeemOutlet]    VARCHAR (3)  DEFAULT ('') NOT NULL,
    [ExpiryDate]      DATETIME     DEFAULT (getdate()) NOT NULL,
    [PropertyId]      INT          NOT NULL,
    [RedeemVoucherNo] VARCHAR (20) DEFAULT ('') NOT NULL
);


GO

