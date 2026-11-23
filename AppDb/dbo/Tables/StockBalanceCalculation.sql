CREATE TABLE [dbo].[StockBalanceCalculation] (
    [ItemId]           INT   NULL,
    [GRN]              MONEY CONSTRAINT [DF_StockBalanceCalculation_GRN] DEFAULT ((0)) NULL,
    [IssueNote]        MONEY CONSTRAINT [DF_StockBalanceCalculation_IssueNote] DEFAULT ((0)) NULL,
    [SupplierReturn]   MONEY CONSTRAINT [DF_StockBalanceCalculation_SupplierReturn] DEFAULT ((0)) NULL,
    [ReconcilationIN]  MONEY CONSTRAINT [DF_StockBalanceCalculation_ReconcilationIN] DEFAULT ((0)) NULL,
    [ReconcilationOut] MONEY CONSTRAINT [DF_StockBalanceCalculation_ReconcilationOut] DEFAULT ((0)) NULL,
    [IssueReturn]      MONEY CONSTRAINT [DF_StockBalanceCalculation_IssueReturn] DEFAULT ((0)) NULL,
    [KitchenIssue]     MONEY CONSTRAINT [DF_StockBalanceCalculation_KitchenIssue] DEFAULT ((0)) NULL,
    [TransferIN]       MONEY CONSTRAINT [DF_StockBalanceCalculation_TransferIN] DEFAULT ((0)) NULL,
    [TransferOut]      MONEY CONSTRAINT [DF_StockBalanceCalculation_TransferOut] DEFAULT ((0)) NULL,
    [Balance]          MONEY CONSTRAINT [DF_StockBalanceCalculation_Balance] DEFAULT ((0)) NULL
);


GO

