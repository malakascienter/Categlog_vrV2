CREATE TABLE [dbo].[RequestHeaders] (
    [Id]                   INT            IDENTITY (1, 1) NOT NULL,
    [PropertyID]           INT            NOT NULL,
    [LocationID]           INT            NOT NULL,
    [DepartmentID]         INT            NOT NULL,
    [TransferLocation]     INT            NOT NULL,
    [RequestType]          NVARCHAR (2)   NULL,
    [DocumentNo]           NVARCHAR (50)  NULL,
    [RequestDate]          DATETIME       NOT NULL,
    [DocumentStatus]       NVARCHAR (MAX) NULL,
    [UserProfileID]        INT            NOT NULL,
    [JobNo]                NVARCHAR (50)  NULL,
    [IsApproved]           BIT            NOT NULL,
    [Remarks]              NVARCHAR (500) NULL,
    [TimeStamp]            NVARCHAR (256) NULL,
    [TransactionTypeCode]  NVARCHAR (3)   NULL,
    [DeliveryDate]         DATETIME       DEFAULT ('1900-01-01T00:00:00.000') NOT NULL,
    [Isprint]              BIT            DEFAULT ((0)) NOT NULL,
    [Flag]                 INT            DEFAULT ((0)) NOT NULL,
    [JobID]                INT            DEFAULT ((0)) NOT NULL,
    [Urgent]               BIT            CONSTRAINT [DF_RequestHeaders_Urgent] DEFAULT ((0)) NOT NULL,
    [SystemDate]           DATETIME       CONSTRAINT [DF_RequestHeaders_SystemDate] DEFAULT (getdate()) NOT NULL,
    [SendMail]             BIT            CONSTRAINT [DF_RequestHeaders_SendMail] DEFAULT ((0)) NULL,
    [LastModUserID]        INT            CONSTRAINT [DF_RequestHeaders_LastModUserID] DEFAULT ((0)) NULL,
    [UrgentRemark]         VARCHAR (200)  DEFAULT ('') NOT NULL,
    [QuotationStatus]      CHAR (2)       CONSTRAINT [DF_RequestHeaders_QuotationStatus] DEFAULT ('P') NULL,
    [PaxCount]             DECIMAL (8, 2) NULL,
    [CommiRequestHeaderID] INT            CONSTRAINT [DF_RequestHeaders_CommiRequestHeaderID] DEFAULT ((0)) NULL,
    [DamageCategoryID]     INT            CONSTRAINT [DF_RequestHeaders_DamageCategoryID] DEFAULT ((0)) NULL,
    [IsSPOBased]           BIT            CONSTRAINT [DF_RequestHeaders_SPOId] DEFAULT ((0)) NOT NULL,
    [SPOId]                INT            CONSTRAINT [DF_RequestHeaders_SPOId1] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_dbo.RequestHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [RequestHeaders_3]
    ON [dbo].[RequestHeaders]([DepartmentID] ASC, [TransactionTypeCode] ASC)
    INCLUDE([PropertyID], [LocationID], [DocumentNo], [RequestDate]);


GO

CREATE NONCLUSTERED INDEX [RequestHeaders_6]
    ON [dbo].[RequestHeaders]([TransferLocation] ASC, [TransactionTypeCode] ASC)
    INCLUDE([PropertyID], [DepartmentID], [DocumentNo], [RequestDate]);


GO

CREATE NONCLUSTERED INDEX [RequestHeaders_5]
    ON [dbo].[RequestHeaders]([TransactionTypeCode] ASC)
    INCLUDE([PropertyID], [DepartmentID], [TransferLocation], [DocumentNo], [RequestDate]);


GO

CREATE NONCLUSTERED INDEX [RequestHeaders_1]
    ON [dbo].[RequestHeaders]([TransactionTypeCode] ASC)
    INCLUDE([PropertyID], [LocationID], [DepartmentID], [DocumentNo], [RequestDate]);


GO

CREATE NONCLUSTERED INDEX [RequestHeaders_4]
    ON [dbo].[RequestHeaders]([LocationID] ASC, [TransactionTypeCode] ASC)
    INCLUDE([PropertyID], [DepartmentID], [DocumentNo], [RequestDate]);


GO

