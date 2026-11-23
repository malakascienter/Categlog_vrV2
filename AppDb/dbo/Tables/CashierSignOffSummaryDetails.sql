CREATE TABLE [dbo].[CashierSignOffSummaryDetails] (
    [ShiftNo]                      INT             NULL,
    [OutletCode]                   CHAR (3)        NULL,
    [OpeningBalance]               DECIMAL (18, 2) NULL,
    [TotCashReceipts]              DECIMAL (18, 2) NULL,
    [Withrawals]                   DECIMAL (18, 2) NULL,
    [CalculatedCashAmount]         DECIMAL (18, 2) NULL,
    [PhysicalAmount]               DECIMAL (18, 2) NULL,
    [TotCashSale]                  DECIMAL (18, 2) NULL,
    [SystemDate]                   DATE            NULL,
    [Variance]                     DECIMAL (18, 2) NULL,
    [CashierSignOnDateTime]        DATETIME        NULL,
    [CashierSignOffAuthorizedUser] VARCHAR (20)    NULL,
    [PropertyId]                   INT             NULL
);


GO

