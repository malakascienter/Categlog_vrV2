CREATE TABLE [dbo].[SupplierEvaluationDetail] (
    [ID]                       INT             IDENTITY (1, 1) NOT NULL,
    [EvaluationHeaderID]       INT             NULL,
    [StockTransactionHeaderID] INT             NULL,
    [CriteriaID]               INT             NULL,
    [MaxMarks]                 DECIMAL (18, 2) NULL,
    [Score]                    DECIMAL (18, 2) NULL,
    [Remarks]                  VARCHAR (250)   NULL,
    [OriginalScore]            DECIMAL (18, 2) NULL,
    [ApproverRemarks]          VARCHAR (250)   NULL,
    [ApproverUserID]           INT             NULL,
    [ApproverModifiedDate]     DATETIME        NULL,
    [BenchMarks]               DECIMAL (18, 2) NULL,
    [TransactionType]          NVARCHAR (3)    NULL,
    [TxnType]                  CHAR (1)        NULL,
    [TransactionDate]          DATE            NULL
);


GO

