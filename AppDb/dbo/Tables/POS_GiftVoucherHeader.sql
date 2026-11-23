CREATE TABLE [dbo].[POS_GiftVoucherHeader] (
    [DocNo]      VARCHAR (10)    NOT NULL,
    [DocDate]    DATETIME        CONSTRAINT [DF_GiftVoucherHeader_DocDate] DEFAULT (getdate()) NOT NULL,
    [Outlet]     VARCHAR (50)    NOT NULL,
    [SubTotal]   NUMERIC (18, 2) NULL,
    [Remarks]    VARCHAR (100)   NULL,
    [SysDate]    DATETIME        CONSTRAINT [DF_GiftVoucherHeader_SysDate] DEFAULT (getdate()) NULL,
    [UserID]     VARCHAR (20)    NULL,
    [Upload]     BIT             CONSTRAINT [DF_GiftVoucherHeader_Upload] DEFAULT ((1)) NOT NULL,
    [PropertyId] INT             NOT NULL,
    CONSTRAINT [PK_GiftVoucherHeader] PRIMARY KEY CLUSTERED ([DocNo] ASC, [Outlet] ASC)
);


GO

