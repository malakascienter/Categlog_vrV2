CREATE TABLE [dbo].[BackendSettings] (
    [QSRMode]               BIT            NULL,
    [ReportServerPwd]       NVARCHAR (MAX) NULL,
    [CurrentDate]           DATETIME       DEFAULT (getdate()) NOT NULL,
    [IsPaymentTypeEnable]   BIT            DEFAULT ((0)) NOT NULL,
    [NextSMSTransactionId]  BIGINT         DEFAULT ((0)) NOT NULL,
    [FinancialYearFromDate] DATE           NULL
);


GO

