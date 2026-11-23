CREATE TABLE [dbo].[RequestionStatus] (
    [ID]                  INT             IDENTITY (1, 1) NOT NULL,
    [TransactionType]     NVARCHAR (5)    NULL,
    [RequestHeaderID]     INT             NULL,
    [TransactionHeaderID] INT             NULL,
    [StockItemID]         INT             NULL,
    [RequestedQty]        DECIMAL (18, 6) NULL,
    [BalanceRequestedQty] DECIMAL (18, 6) NULL,
    [RecievedQty]         DECIMAL (18, 6) NULL,
    [SysDateTime]         DATETIME        NULL
);


GO

