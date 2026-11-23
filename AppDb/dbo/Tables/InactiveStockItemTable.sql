CREATE TABLE [dbo].[InactiveStockItemTable] (
    [ID]            INT            IDENTITY (1, 1) NOT NULL,
    [StockItemCode] NVARCHAR (MAX) NULL,
    [StockItemID]   INT            NULL,
    [LocationID]    INT            NULL,
    [PropertyID]    INT            NULL
);


GO

