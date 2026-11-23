CREATE TABLE [dbo].[StockReconcilationExcelTemp] (
    [ID]            INT             IDENTITY (1, 1) NOT NULL,
    [Quantity]      FLOAT (53)      NOT NULL,
    [StockItemCode] VARCHAR (200)   NULL,
    [StockName]     VARCHAR (200)   NULL,
    [UnitName]      VARCHAR (200)   NULL,
    [UnitPrice]     DECIMAL (18, 8) NULL,
    [Remark]        VARCHAR (200)   NULL,
    [RowNum]        INT             NULL
);


GO

