CREATE TABLE [dbo].[CashierSignOffPaymentDetails] (
    [Desccription]   NVARCHAR (250) NULL,
    [SystemAmount]   MONEY          NULL,
    [PhysicalAmount] MONEY          NULL,
    [Variance]       MONEY          NULL,
    [SystemDate]     DATETIME       NULL,
    [ShiftNo]        INT            NOT NULL,
    [OutletCode]     CHAR (3)       NULL,
    [PropertyId]     INT            NULL
);


GO

