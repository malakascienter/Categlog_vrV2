CREATE TABLE [dbo].[StockItemWiseEXPDateIns] (
    [ID]              INT             IDENTITY (1, 1) NOT NULL,
    [PropertyID]      INT             NOT NULL,
    [LocationID]      INT             NOT NULL,
    [TransactionID]   NVARCHAR (MAX)  NULL,
    [TransactionType] NVARCHAR (MAX)  NULL,
    [StockItemID]     BIGINT          NOT NULL,
    [Quantity]        DECIMAL (18, 8) NOT NULL,
    [BalanceQuantity] DECIMAL (18, 8) NOT NULL,
    [EXPDate]         DATETIME        NOT NULL,
    [LogDate]         DATETIME        CONSTRAINT [DF__StockItem__LogDa__292D09F3] DEFAULT (getdate()) NOT NULL,
    [BatchNo]         VARCHAR (200)   CONSTRAINT [DF_StockItemWiseEXPDateIns_BatchNO] DEFAULT ('N/A') NULL,
    [TxnUnitID]       INT             CONSTRAINT [DF_StockItemWiseEXPDateIns_TxnUnitID] DEFAULT ((0)) NULL,
    [StockMasterQty]  DECIMAL (18, 8) CONSTRAINT [DF_StockItemWiseEXPDateIns_StockMasterQty] DEFAULT ((0)) NULL,
    [TransactionDate] DATE            CONSTRAINT [DF_StockItemWiseEXPDateIns_TransactionDate] DEFAULT (getdate()) NULL,
    [MasterUnitID]    INT             CONSTRAINT [DF_StockItemWiseEXPDateIns_MasterUnitID] DEFAULT ((0)) NULL,
    [PhysicalQty]     DECIMAL (18, 8) CONSTRAINT [DF_StockItemWiseEXPDateIns_PhysicalQty] DEFAULT ((0)) NULL,
    [TxnType]         CHAR (1)        NULL,
    [SellingPrice]    DECIMAL (18, 8) NULL,
    [ReferenceNo]     INT             NULL,
    CONSTRAINT [PK_dbo.StockItemWiseEXPDateIns] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IDX_StockItemWiseEXPDateIns]
    ON [dbo].[StockItemWiseEXPDateIns]([LocationID] ASC, [StockItemID] ASC, [BatchNo] ASC, [EXPDate] ASC, [ID] ASC)
    INCLUDE([Quantity]);


GO

