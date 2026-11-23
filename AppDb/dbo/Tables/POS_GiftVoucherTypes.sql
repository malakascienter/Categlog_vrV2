CREATE TABLE [dbo].[POS_GiftVoucherTypes] (
    [TypeID]        INT         IDENTITY (1, 1) NOT NULL,
    [VoucherMode]   VARCHAR (2) DEFAULT ('') NOT NULL,
    [TypePrefix]    VARCHAR (2) DEFAULT ('') NOT NULL,
    [Amount]        INT         DEFAULT ((0)) NOT NULL,
    [PropertyId]    INT         NOT NULL,
    [NextVoucherNo] INT         DEFAULT ((0)) NOT NULL
);


GO

