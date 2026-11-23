CREATE TABLE [dbo].[StockTransactionwiseCharges] (
    [StockTransactionwiseChangesID] BIGINT          IDENTITY (1, 1) NOT NULL,
    [StockTransactionHeaderID]      BIGINT          NOT NULL,
    [AdditionalChargeID]            BIGINT          NOT NULL,
    [ChargeAmount]                  DECIMAL (18, 6) NOT NULL,
    [AddedToItemCost]               BIT             NOT NULL,
    CONSTRAINT [PK_dbo.StockTransactionwiseCharges] PRIMARY KEY CLUSTERED ([StockTransactionwiseChangesID] ASC)
);


GO

