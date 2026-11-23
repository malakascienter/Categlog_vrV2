CREATE TABLE [dbo].[StockTransactionDetails] (
    [Id]                           INT             IDENTITY (1, 1) NOT NULL,
    [StockTransactionHeaderID]     INT             NOT NULL,
    [StockItemID]                  INT             NOT NULL,
    [Quantity]                     DECIMAL (18, 6) NOT NULL,
    [UnitPrice]                    DECIMAL (18, 6) NOT NULL,
    [TxnUnitID]                    INT             NOT NULL,
    [MasterUnitID]                 INT             NOT NULL,
    [MasterUnitConversion]         DECIMAL (18, 6) NOT NULL,
    [ReportUnitID]                 INT             NOT NULL,
    [ReportUnitConversion]         DECIMAL (18, 6) NOT NULL,
    [DiscountValue]                DECIMAL (18, 6) NOT NULL,
    [DiscountPercentage]           DECIMAL (18, 6) NOT NULL,
    [TimeStamp]                    NVARCHAR (256)  NULL,
    [StockMasterQuantity]          DECIMAL (18, 6) NOT NULL,
    [StockMasterAveragePrice]      DECIMAL (18, 6) NOT NULL,
    [NewQuantity]                  DECIMAL (18, 6) NOT NULL,
    [NewAveragePrice]              DECIMAL (18, 6) NOT NULL,
    [Remarks]                      NVARCHAR (MAX)  NULL,
    [UserProfileId]                INT             NOT NULL,
    [CostTransactionAccountID]     INT             NOT NULL,
    [PurchaseTransactionAccountID] INT             NOT NULL,
    [TxnType]                      NVARCHAR (1)    NULL,
    [BalanceQuantity]              DECIMAL (18, 6) NOT NULL,
    [ReturnQuantity]               DECIMAL (18, 6) NOT NULL,
    [ItemUnitPriceInSuppCurrency]  DECIMAL (18, 6) NOT NULL,
    [IPAddress]                    NVARCHAR (MAX)  NULL,
    [CreatedUserID]                INT             NOT NULL,
    [LastModUserID]                INT             NOT NULL,
    [CreatedDate]                  DATETIME        NOT NULL,
    [LastModDate]                  DATETIME        NOT NULL,
    [TBPHeaderId]                  INT             CONSTRAINT [DF__StockTran__TBPHe__548C6944] DEFAULT ((0)) NOT NULL,
    [Isserialadded]                BIT             CONSTRAINT [DF_StockTransactionDetails_Isserialadded] DEFAULT ((0)) NOT NULL,
    [SkipGL]                       BIT             CONSTRAINT [DF__StockTran__SkipG__2A212E2C] DEFAULT ((0)) NOT NULL,
    [BalVal]                       DECIMAL (38, 8) CONSTRAINT [DF_StockTransactionDetails_BalVal] DEFAULT ((0)) NULL,
    [AccName]                      NVARCHAR (250)  NULL,
    [RequestedGenericItemId]       INT             NULL,
    [PhysicalQuantity]             DECIMAL (18, 6) CONSTRAINT [DF_StockTransactionDetails_PhysicalQuantity] DEFAULT ((0)) NULL,
    [IssuedQuantity]               DECIMAL (18, 6) CONSTRAINT [DF_StockTransactionDetails_IssuedQuantity] DEFAULT ((0)) NOT NULL,
    [SellingPrice]                 DECIMAL (18, 6) DEFAULT ((0)) NOT NULL,
    [SelectedCUSDECID]             INT             CONSTRAINT [DF_StockTransactionDetails_CUSDECID] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_dbo.StockTransactionDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [StockTransactionDetails_StockTransactionHeaderID_StockTransactionHeaderID]
    ON [dbo].[StockTransactionDetails]([StockTransactionHeaderID] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_txn1]
    ON [dbo].[StockTransactionDetails]([StockItemID] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_TransDetails_Item]
    ON [dbo].[StockTransactionDetails]([StockItemID] ASC, [StockTransactionHeaderID] ASC)
    INCLUDE([NewQuantity], [NewAveragePrice]);


GO

CREATE NONCLUSTERED INDEX [IDX_StockTransactionDetails]
    ON [dbo].[StockTransactionDetails]([StockTransactionHeaderID] ASC, [StockItemID] ASC, [NewQuantity] ASC, [NewAveragePrice] ASC)
    INCLUDE([Quantity]);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Column to store related CUSDEC GRN ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StockTransactionDetails', @level2type = N'COLUMN', @level2name = N'SelectedCUSDECID';


GO

