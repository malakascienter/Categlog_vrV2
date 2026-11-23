CREATE TABLE [dbo].[POS_InvoiceHeader] (
    [InvHeaderID]            BIGINT          IDENTITY (1, 1) NOT NULL,
    [CompanyID]              TINYINT         CONSTRAINT [DF_POS_InvoiceHeader_CompanyID] DEFAULT ((0)) NOT NULL,
    [InvoiceNo]              VARCHAR (20)    NOT NULL,
    [BusinessDate]           DATE            CONSTRAINT [DF_POS_InvoiceHeader_BusinessDate] DEFAULT (getdate()) NOT NULL,
    [InsertDateTime]         DATETIME        NOT NULL,
    [UserID]                 INT             CONSTRAINT [DF_POS_InvoiceHeader_UserID] DEFAULT ((0)) NOT NULL,
    [StationID]              TINYINT         NOT NULL,
    [LocationID]             INT             CONSTRAINT [DF_POS_InvoiceHeader_LocationID] DEFAULT ((0)) NOT NULL,
    [SubAmount]              NUMERIC (18, 8) CONSTRAINT [DF_POS_InvoiceHeader_SubAmount] DEFAULT ((0)) NOT NULL,
    [Discount]               NUMERIC (18, 8) CONSTRAINT [DF_Table_1_SubAmount1] DEFAULT ((0)) NOT NULL,
    [TotalCharges]           NUMERIC (18, 8) CONSTRAINT [DF_Table_1_Discount1] DEFAULT ((0)) NOT NULL,
    [NetAmount]              NUMERIC (18, 8) CONSTRAINT [DF_Table_1_TotalCharges1] DEFAULT ((0)) NOT NULL,
    [IsPaidCommission]       BIT             DEFAULT ((0)) NOT NULL,
    [GuideID]                INT             CONSTRAINT [DF_POS_InvoiceHeader_GuideID] DEFAULT ((0)) NULL,
    [GuideCompanyPercentage] NUMERIC (18, 2) CONSTRAINT [DF_POS_InvoiceHeader_GuideCompanyPercentage] DEFAULT ((0)) NULL,
    [GuidePercentage]        NUMERIC (18, 2) CONSTRAINT [DF_POS_InvoiceHeader_GuidePercentage] DEFAULT ((0)) NULL,
    [GuideCompanyID]         INT             CONSTRAINT [DF_POS_InvoiceHeader_GuideCompanyID] DEFAULT ((0)) NULL
);


GO

