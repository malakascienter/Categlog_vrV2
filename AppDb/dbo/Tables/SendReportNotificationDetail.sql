CREATE TABLE [dbo].[SendReportNotificationDetail] (
    [Id]           INT            IDENTITY (1, 1) NOT NULL,
    [ReportType]   NVARCHAR (50)  NULL,
    [ReportTypeID] INT            NULL,
    [ReportDate]   DATE           NULL,
    [ReportData]   NVARCHAR (MAX) NULL,
    [EmailSubject] NVARCHAR (500) NULL,
    [IsMailSend]   BIT            CONSTRAINT [DF_SendReportNotificationDetail_IsMailSend] DEFAULT ((0)) NOT NULL,
    [SysDate]      DATETIME       CONSTRAINT [DF_SendReportNotificationDetail_SysDate] DEFAULT (getdate()) NOT NULL
);


GO

