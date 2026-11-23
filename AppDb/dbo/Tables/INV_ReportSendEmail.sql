CREATE TABLE [dbo].[INV_ReportSendEmail] (
    [Name]                           VARCHAR (100) CONSTRAINT [DF_INV_ReportSendEmail_Name] DEFAULT ('') NOT NULL,
    [HotelCode]                      VARCHAR (3)   CONSTRAINT [DF_INV_ReportSendEmail_HotelCode] DEFAULT ('') NOT NULL,
    [EMailAddress]                   VARCHAR (100) CONSTRAINT [DF_INV_ReportSendEmail_EMailAddress] DEFAULT ('') NOT NULL,
    [IsActive]                       BIT           CONSTRAINT [DF_INV_ReportSendEmail_IsActive] DEFAULT ((0)) NOT NULL,
    [LastSendDate]                   DATETIME      CONSTRAINT [DF_INV_ReportSendEmail_LastSendDate] DEFAULT (getdate()) NOT NULL,
    [EmailTo]                        BIT           NULL,
    [EmailCC]                        BIT           NULL,
    [EmailBCC]                       BIT           NULL,
    [IsDailySalesAnalysisNeedToSend] BIT           CONSTRAINT [DF_INV_ReportSendEmail_IsDailySalesAnalysisNeedToSend] DEFAULT ((0)) NOT NULL,
    [DailySalesAnalysisLastSentOn]   DATETIME      CONSTRAINT [DF_INV_ReportSendEmail_DailySalesAnalysisLastSentOn] DEFAULT (getdate()) NOT NULL,
    [IsHourlyUpload]                 BIT           CONSTRAINT [DF_INV_ReportSendEmail_IsHourlyUpload] DEFAULT ((0)) NOT NULL,
    [IsMorningSummary]               BIT           CONSTRAINT [DF_INV_ReportSendEmail_IsMorningSummary] DEFAULT ((0)) NOT NULL,
    [IsOracleIntegrationEmail]       BIT           NOT NULL,
    [SysDate]                        DATETIME      CONSTRAINT [DF_INV_ReportSendEmail_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsBrandWiseMail]                BIT           DEFAULT ((0)) NOT NULL,
    [ID]                             BIGINT        IDENTITY (1, 1) NOT NULL,
    [EODMail]                        BIT           DEFAULT ((0)) NOT NULL,
    [IsOutletWiseSend]               BIT           DEFAULT ((0)) NOT NULL,
    [Outlet]                         VARCHAR (5)   DEFAULT ('') NOT NULL,
    [PropertyID]                     INT           NULL,
    [LocationID]                     INT           NULL,
    [IsRetailSalesMail]              BIT           CONSTRAINT [DF_INV_ReportSendEmail_IsRetailSalesMail] DEFAULT ((0)) NOT NULL,
    [RetailSalesLastSentOn]          DATETIME      NULL,
    CONSTRAINT [PK_INV_ReportSendEmail] PRIMARY KEY CLUSTERED ([EMailAddress] ASC)
);


GO

