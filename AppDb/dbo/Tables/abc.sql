CREATE TABLE [dbo].[abc] (
    [PoDetailID]        INT            NOT NULL,
    [PoHeaderID]        INT            NOT NULL,
    [StockItemID]       INT            NOT NULL,
    [StockItemCode]     INT            NOT NULL,
    [ItemName]          NVARCHAR (MAX) NULL,
    [UnitCode]          INT            NOT NULL,
    [UnitName]          NVARCHAR (MAX) NULL,
    [RequestedQuantity] FLOAT (53)     NOT NULL,
    [ApprovedQuantity]  FLOAT (53)     NOT NULL,
    [ReceivedQuantity]  FLOAT (53)     NOT NULL,
    [Remarks]           NVARCHAR (500) NULL
);


GO

