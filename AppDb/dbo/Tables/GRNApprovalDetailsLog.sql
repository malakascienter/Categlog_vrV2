CREATE TABLE [dbo].[GRNApprovalDetailsLog] (
    [ID]                       INT             IDENTITY (1, 1) NOT NULL,
    [GRNApprovalLogID]         INT             NOT NULL,
    [ApprovalDocNo]            VARCHAR (MAX)   NULL,
    [GRNPrice]                 DECIMAL (18, 6) NULL,
    [ApprovedPrice]            DECIMAL (18, 6) NULL,
    [UserID]                   INT             NULL,
    [UserName]                 NCHAR (10)      NULL,
    [SeqID]                    INT             NULL,
    [ApprovalLevelID]          INT             NULL,
    [ApprovalDate]             DATETIME        NULL,
    [StockTransactionHeaderID] INT             NULL,
    [GRNQuantity]              DECIMAL (18, 6) NULL,
    [ApprovedQuantity]         DECIMAL (18, 6) NULL,
    [GRNTxnUnitId]             INT             NULL,
    [ApprovedTxnUnitId]        INT             NULL
);


GO

