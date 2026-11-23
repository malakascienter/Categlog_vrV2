CREATE TABLE [dbo].[SendReport] (
    [Id]                    INT             NULL,
    [ReportPath]            NVARCHAR (1000) NULL,
    [ReportSavePath]        NVARCHAR (1000) NULL,
    [SendReportCount]       INT             CONSTRAINT [DF_SendReport_SendReportCount] DEFAULT ((0)) NOT NULL,
    [EODDetailsModel]       NVARCHAR (MAX)  NULL,
    [ReportType]            VARCHAR (50)    NULL,
    [ReportTypeDescription] VARCHAR (200)   NULL,
    [RecipientListSP]       NVARCHAR (200)  NULL,
    [RecipentListParam]     NVARCHAR (MAX)  NULL,
    [ReportParameter]       NVARCHAR (MAX)  NULL,
    [EmailSubject]          NVARCHAR (MAX)  NULL,
    [IsNeedToCC]            BIT             CONSTRAINT [DF_SendReport_IsNeedToCC] DEFAULT ((0)) NOT NULL,
    [SendReportDataModel]   NVARCHAR (MAX)  NULL,
    [ReportServerID]        INT             NULL,
    [EmailBody]             NVARCHAR (MAX)  NULL
);


GO

