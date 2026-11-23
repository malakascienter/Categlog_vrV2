CREATE TABLE [dbo].[RequestWiseTransactions] (
    [ID]                   INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]           INT             NULL,
    [LocationID]           INT             NULL,
    [TransactionType]      VARCHAR (3)     NULL,
    [RequestTransactionID] INT             NULL,
    [StockItemID]          INT             NULL,
    [StockTransactionID]   INT             NULL,
    [RequestedQty]         DECIMAL (18, 6) NULL,
    [RecievedQty]          DECIMAL (18, 6) NULL,
    [CreatedUserID]        INT             NULL,
    [CreatedDate]          DATETIME        NULL,
    [Remark]               VARCHAR (MAX)   NULL
);


GO

