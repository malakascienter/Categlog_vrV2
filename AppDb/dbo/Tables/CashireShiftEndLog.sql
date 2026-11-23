CREATE TABLE [dbo].[CashireShiftEndLog] (
    [ShiftNo]      VARCHAR (10)    NULL,
    [Cashireid]    VARCHAR (20)    NULL,
    [dType]        VARCHAR (50)    NULL,
    [nos]          INT             NULL,
    [value]        MONEY           NULL,
    [sysdate]      DATETIME        CONSTRAINT [DF_CashireShiftEndLog_sysdate] DEFAULT (getdate()) NOT NULL,
    [IsCash]       BIT             CONSTRAINT [DF_CashireShiftEndLog_IsCash] DEFAULT ((0)) NOT NULL,
    [Outlet]       CHAR (3)        CONSTRAINT [DF_CashireShiftEndLog_Outlet] DEFAULT ((1)) NOT NULL,
    [PropertyId]   INT             NOT NULL,
    [PayCode]      VARCHAR (5)     DEFAULT ('') NOT NULL,
    [SystemAmount] DECIMAL (18, 6) DEFAULT ((0)) NOT NULL
);


GO

