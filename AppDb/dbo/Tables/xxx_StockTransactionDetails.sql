CREATE TABLE [dbo].[xxx_StockTransactionDetails] (
    [StockItemCode] NVARCHAR (MAX)  NULL,
    [Name]          NVARCHAR (MAX)  NULL,
    [Quantity]      DECIMAL (18, 2) NOT NULL,
    [UnitPrice]     DECIMAL (18, 2) NOT NULL,
    [TaxAmount]     INT             NOT NULL,
    [discont]       INT             NOT NULL,
    [UnitName]      NVARCHAR (MAX)  NULL,
    [netammount]    INT             NOT NULL,
    [grossAmmount]  DECIMAL (37, 4) NULL
);


GO

