CREATE TABLE [dbo].[CashierSignOffUserDetails] (
    [ShiftNo]            INT             NULL,
    [ShiftDate]          DATETIME        NULL,
    [Location]           NVARCHAR (500)  NULL,
    [Users]              NVARCHAR (250)  NULL,
    [SystemDate]         DATETIME        NULL,
    [Station]            NVARCHAR (250)  NULL,
    [StartingInvoiceNo]  NVARCHAR (250)  NULL,
    [EndingInvoiceNo]    NVARCHAR (250)  NULL,
    [InvoiceCount]       INT             NULL,
    [CancelInvoiceCount] INT             NULL,
    [OutletCode]         CHAR (3)        NULL,
    [ReturnExchange]     DECIMAL (18, 2) NULL,
    [TotalDiscount]      DECIMAL (18, 2) NULL,
    [PropertyId]         INT             NULL
);


GO

