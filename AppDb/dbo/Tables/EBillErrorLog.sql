CREATE TABLE [dbo].[EBillErrorLog] (
    [ID]           INT           IDENTITY (1, 1) NOT NULL,
    [OrderNo]      VARCHAR (10)  NULL,
    [OrderDate]    DATETIME      NULL,
    [Outlet]       VARCHAR (5)   NULL,
    [ErrorMassage] VARCHAR (MAX) NULL,
    [SysDate]      DATETIME      CONSTRAINT [DF_EBillErrorLog_SysDate] DEFAULT (getdate()) NOT NULL,
    [PropertyId]   INT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EBillErrorLog] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

