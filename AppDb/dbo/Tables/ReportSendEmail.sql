CREATE TABLE [dbo].[ReportSendEmail] (
    [Name]                           VARCHAR (100) CONSTRAINT [DF_ReportSendEmail_Name] DEFAULT ('') NOT NULL,
    [HotelCode]                      VARCHAR (3)   CONSTRAINT [DF_ReportSendEmail_HotelCode] DEFAULT ('') NOT NULL,
    [EMailAddress]                   VARCHAR (100) CONSTRAINT [DF_ReportSendEmail_EMailAddress] DEFAULT ('') NOT NULL,
    [IsActive]                       BIT           CONSTRAINT [DF_ReportSendEmail_IsActive] DEFAULT ((0)) NOT NULL,
    [LastSendDate]                   DATETIME      CONSTRAINT [DF_ReportSendEmail_LastSendDate] DEFAULT (getdate()) NOT NULL,
    [EmailTo]                        BIT           NULL,
    [EmailCC]                        BIT           NULL,
    [EmailBCC]                       BIT           NULL,
    [IsDailySalesAnalysisNeedToSend] BIT           CONSTRAINT [DF_ReportSendEmail_IsDailySalesAnalysisNeedToSend] DEFAULT ((0)) NOT NULL,
    [DailySalesAnalysisLastSentOn]   DATETIME      CONSTRAINT [DF_ReportSendEmail_DailySalesAnalysisLastSentOn] DEFAULT (getdate()) NOT NULL,
    [IsHourlyUpload]                 BIT           CONSTRAINT [DF_ReportSendEmail_IsHourlyUpload] DEFAULT ((0)) NOT NULL,
    [IsMorningSummary]               BIT           CONSTRAINT [DF_ReportSendEmail_IsMorningSummary] DEFAULT ((0)) NOT NULL,
    [IsOracleIntegrationEmail]       BIT           CONSTRAINT [DF__ReportSen__IsOra__406268B8] DEFAULT ((0)) NOT NULL,
    [SysDate]                        DATETIME      CONSTRAINT [DF_ReportSendEmail_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsBrandWiseMail]                BIT           DEFAULT ((0)) NOT NULL,
    [ID]                             BIGINT        IDENTITY (1, 1) NOT NULL,
    [EODMail]                        BIT           DEFAULT ((0)) NOT NULL,
    [IsOutletWiseSend]               BIT           DEFAULT ((0)) NOT NULL,
    [Outlet]                         VARCHAR (5)   DEFAULT ('') NOT NULL,
    CONSTRAINT [PK_ReportSendEmail] PRIMARY KEY CLUSTERED ([EMailAddress] ASC)
);


GO

