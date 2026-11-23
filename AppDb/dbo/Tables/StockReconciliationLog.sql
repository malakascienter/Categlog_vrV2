CREATE TABLE [dbo].[StockReconciliationLog] (
    [ID]                       INT             IDENTITY (1, 1) NOT NULL,
    [ApprovalLogID]            INT             NOT NULL,
    [ApprovalDocNo]            VARCHAR (MAX)   NULL,
    [ReceivedQuantity]         DECIMAL (18, 6) NULL,
    [ApprovedQuantity]         DECIMAL (18, 6) NULL,
    [UserID]                   INT             NULL,
    [UserName]                 NCHAR (10)      NULL,
    [ApprovalLevelID]          INT             NULL,
    [SeqID]                    INT             NULL,
    [CreatedDate]              DATETIME        NOT NULL,
    [StockTransactionHeaderID] INT             NULL
);


GO

