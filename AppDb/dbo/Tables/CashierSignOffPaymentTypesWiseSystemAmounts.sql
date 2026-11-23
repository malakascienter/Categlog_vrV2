CREATE TABLE [dbo].[CashierSignOffPaymentTypesWiseSystemAmounts] (
    [PayCode]      VARCHAR (10)    NOT NULL,
    [SystemAmount] DECIMAL (18, 4) NOT NULL,
    [ShiftId]      INT             NOT NULL,
    [ShiftDate]    DATETIME        NOT NULL,
    [Outlet]       VARCHAR (10)    NOT NULL,
    [PropertyId]   INT             NULL
);


GO

