CREATE TABLE [dbo].[StockReplenishmentLog] (
    [Id]              INT             IDENTITY (1, 1) NOT NULL,
    [StockItemId]     INT             NULL,
    [LocationID]      INT             NULL,
    [UnitID]          INT             NULL,
    [CompanyID]       INT             NULL,
    [QuantityInHand]  DECIMAL (18, 4) NULL,
    [ReOrderLevel]    DECIMAL (18, 4) NULL,
    [ReOrderQuantity] DECIMAL (18, 4) NULL,
    [SystemDate]      DATETIME        CONSTRAINT [DF_StockReplenishmentLog_SystemDate] DEFAULT (getdate()) NOT NULL
);


GO

