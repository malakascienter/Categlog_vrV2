CREATE TABLE [dbo].[StockTransactionWiseBudgetPayment] (
    [ID]                       INT             IDENTITY (1, 1) NOT NULL,
    [StockTransactionHeaderID] INT             NULL,
    [PaidAmount]               DECIMAL (18, 8) NULL,
    [BudgetID]                 INT             NULL,
    [UserID]                   INT             NULL,
    [SysDateTime]              DATETIME        CONSTRAINT [DF_StockTransactionWiseBudgetPayment_SysDateTime] DEFAULT (getdate()) NULL
);


GO

