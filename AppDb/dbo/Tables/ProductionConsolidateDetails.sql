CREATE TABLE [dbo].[ProductionConsolidateDetails] (
    [ID]                  INT             IDENTITY (1, 1) NOT NULL,
    [HeaderID]            INT             NULL,
    [StockItemID]         INT             NULL,
    [RequestedQTY]        DECIMAL (18, 6) NULL,
    [ProductionQuantity]  DECIMAL (18, 6) NULL,
    [QuantityInHand]      DECIMAL (18, 6) NULL,
    [SysDateTime]         DATETIME        NULL,
    [TransactionRefId]    BIGINT          DEFAULT ((0)) NOT NULL,
    [IsProductionProcess] BIGINT          DEFAULT ((0)) NOT NULL,
    [MasterUnitID]        INT             NULL,
    [ProceedQty]          DECIMAL (18, 6) DEFAULT ((0)) NOT NULL
);


GO

