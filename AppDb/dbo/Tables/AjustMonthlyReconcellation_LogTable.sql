CREATE TABLE [dbo].[AjustMonthlyReconcellation_LogTable] (
    [ID]                     INT      IDENTITY (1, 1) NOT NULL,
    [locationId]             INT      NULL,
    [StockItemID]            INT      NULL,
    [txnDate]                DATETIME NULL,
    [newTransactionHeaderID] INT      NULL,
    [NewQuantity]            MONEY    NULL,
    [NewAveragePrice]        MONEY    NULL,
    [Difference]             MONEY    NULL,
    [Variance]               MONEY    NULL,
    [varyqty]                MONEY    NULL,
    [LastRecored]            INT      NULL
);


GO

