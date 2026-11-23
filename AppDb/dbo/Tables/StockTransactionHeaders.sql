CREATE TABLE [dbo].[StockTransactionHeaders] (
    [Id]                        INT              IDENTITY (1, 1) NOT NULL,
    [DocumentNo]                NVARCHAR (20)    NULL,
    [TransactionType]           NVARCHAR (2)     NULL,
    [TransactionDate]           DATE             NOT NULL,
    [PropertyID]                INT              NOT NULL,
    [LocationID]                INT              NOT NULL,
    [ReferenceNo]               VARCHAR (MAX)    NULL,
    [SupplierID]                INT              NOT NULL,
    [Remarks]                   NVARCHAR (MAX)   NULL,
    [ReferenceID]               INT              NOT NULL,
    [DepartmentID]              INT              NOT NULL,
    [UserProfileID]             INT              NOT NULL,
    [TransferLocationID]        INT              CONSTRAINT [DF_StockTransactionHeaders_TransferLocationID] DEFAULT ((0)) NOT NULL,
    [TimeStamp]                 NVARCHAR (256)   NULL,
    [TransactionID]             INT              NOT NULL,
    [Mode]                      NVARCHAR (1)     NULL,
    [SuppCurrencyID]            INT              CONSTRAINT [DF_StockTransactionHeaders_SuppCurrencyID] DEFAULT ((0)) NOT NULL,
    [ExchangeRate]              DECIMAL (18, 2)  CONSTRAINT [DF_StockTransactionHeaders_ExchangeRate] DEFAULT ((1)) NOT NULL,
    [IPAddress]                 NVARCHAR (MAX)   NULL,
    [CreatedUserID]             INT              NOT NULL,
    [LastModUserID]             INT              NOT NULL,
    [CreatedDate]               DATETIME         CONSTRAINT [DF_StockTransactionHeaders_CreatedDate] DEFAULT (getdate()) NOT NULL,
    [LastModDate]               DATETIME         CONSTRAINT [DF_StockTransactionHeaders_LastModDate] DEFAULT (getdate()) NOT NULL,
    [IsPrint]                   BIT              CONSTRAINT [DF_StockTransactionHeaders_IsPrint] DEFAULT ((0)) NOT NULL,
    [IsApproved]                BIT              CONSTRAINT [DF_StockTransactionHeaders_IsApproved] DEFAULT ((0)) NOT NULL,
    [IsTrasferIn]               BIT              CONSTRAINT [DF_StockTransactionHeaders_IsTrasferIn] DEFAULT ((0)) NOT NULL,
    [InvoiceDate]               DATETIME         NULL,
    [GLDATE]                    DATE             CONSTRAINT [DF_StockTransactionHeaders_GLDATE] DEFAULT (getdate()) NOT NULL,
    [IsDirectIssue]             BIT              NULL,
    [GRNTypeID]                 INT              CONSTRAINT [DF_StockTransactionHeaders_GRNTypeID] DEFAULT ((0)) NULL,
    [BudgetID]                  INT              CONSTRAINT [DF_StockTransactionHeaders_BudgetID] DEFAULT ((0)) NULL,
    [PaidAmount]                DECIMAL (18, 8)  CONSTRAINT [DF_StockTransactionHeaders_PaidAmount] DEFAULT ((0)) NULL,
    [SendMail]                  BIT              CONSTRAINT [DF_StockTransactionHeaders_SendMail] DEFAULT ((0)) NULL,
    [IsProdGenerate]            BIT              CONSTRAINT [DF__StockTran__IsPro__61611887] DEFAULT ((0)) NOT NULL,
    [IsProductionPlan]          BIT              CONSTRAINT [DF_StockTransactionHeaders_IsProductionPlan] DEFAULT ((0)) NULL,
    [FileName]                  NVARCHAR (MAX)   CONSTRAINT [DF_StockTransactionHeaders_FileName] DEFAULT ('') NULL,
    [PaxCount]                  DECIMAL (8, 2)   NULL,
    [SubstractNetValue]         DECIMAL (18, 2)  CONSTRAINT [DF_StockTransactionHeaders_SubstractNetValue] DEFAULT ((0)) NOT NULL,
    [DamageCategoryID]          INT              CONSTRAINT [DF_StockTransactionHeaders_DamageCategoryID] DEFAULT ((0)) NULL,
    [IsAutoTrasferGRN]          BIT              CONSTRAINT [DF_StockTransactionHeaders_IsAutoTrasferGRN] DEFAULT ((0)) NOT NULL,
    [InvoiceLocationID]         INT              CONSTRAINT [DF_StockTransactionHeaders_InvoiceLocationID] DEFAULT ((0)) NULL,
    [InvoiceDocStatus]          CHAR (1)         NULL,
    [IsInvoiceBasedTransaction] BIT              CONSTRAINT [DF_StockTransactionHeaders_IsInvoiceBasedTransaction] DEFAULT ((0)) NULL,
    [SubmitToken]               UNIQUEIDENTIFIER NULL,
    [TaxInvoiceNumber]          VARCHAR (MAX)    NULL,
    [InvoiceDueDate]            DATETIME         NULL,
    CONSTRAINT [PK_dbo.StockTransactionHeaders] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_STH_SubmitToken]
    ON [dbo].[StockTransactionHeaders]([SubmitToken] ASC) WHERE ([SubmitToken] IS NOT NULL);


GO

CREATE NONCLUSTERED INDEX [IX_Trans_Location_Date]
    ON [dbo].[StockTransactionHeaders]([LocationID] ASC, [TransactionDate] ASC, [CreatedDate] ASC)
    INCLUDE([Id], [TransactionType]);


GO

CREATE NONCLUSTERED INDEX [IDX_StockTransactionHeaders]
    ON [dbo].[StockTransactionHeaders]([Id] ASC, [LocationID] ASC, [TransactionDate] ASC, [CreatedDate] ASC);


GO

