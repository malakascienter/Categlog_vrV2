CREATE TABLE [dbo].[CashierVarianceLog] (
    [TxnDate]     DATETIME      NULL,
    [CashierID]   VARCHAR (100) NULL,
    [ShiftId]     INT           NULL,
    [Paycode]     VARCHAR (10)  NULL,
    [PaymentType] VARCHAR (100) NULL,
    [Variance]    MONEY         NULL,
    [Remark]      VARCHAR (MAX) NULL,
    [Outlet]      VARCHAR (3)   NULL,
    [SysDate]     DATETIME      NULL,
    [CashierName] VARCHAR (250) NULL,
    [PropertyId]  INT           NULL
);


GO

