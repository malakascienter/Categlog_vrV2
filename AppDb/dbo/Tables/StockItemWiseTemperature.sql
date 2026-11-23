CREATE TABLE [dbo].[StockItemWiseTemperature] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]      INT             NOT NULL,
    [LocationID]      INT             NOT NULL,
    [TransactonID]    INT             NOT NULL,
    [TransactionType] NVARCHAR (10)   NULL,
    [StockItemID]     INT             NOT NULL,
    [Quantity]        DECIMAL (18, 6) NOT NULL,
    [Temperature]     DECIMAL (18, 6) NOT NULL,
    [LogDate]         DATETIME        NOT NULL,
    [TypeId]          INT             NOT NULL
);


GO

