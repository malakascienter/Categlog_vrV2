CREATE TABLE [dbo].[EBillSMSView] (
    [ID]          BIGINT         IDENTITY (1, 1) NOT NULL,
    [BillDetails] NVARCHAR (MAX) NOT NULL,
    [OrderId]     NVARCHAR (MAX) NOT NULL,
    [SysDate]     DATETIME       CONSTRAINT [DF_EBillSMSView_SysDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_EBillSMSView] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

