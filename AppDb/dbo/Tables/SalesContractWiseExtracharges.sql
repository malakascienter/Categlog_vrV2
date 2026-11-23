CREATE TABLE [dbo].[SalesContractWiseExtracharges] (
    [Id]                    INT             IDENTITY (1, 1) NOT NULL,
    [SalesContractHeaderID] BIGINT          NOT NULL,
    [StockItemHeaderID]     BIGINT          NOT NULL,
    [ExtrachargeMasterID]   BIGINT          NOT NULL,
    [ChargeType]            NVARCHAR (MAX)  NULL,
    [ChargeRate]            DECIMAL (18, 2) NOT NULL,
    [ChargeAmountPerItem]   DECIMAL (18, 2) NOT NULL,
    [ItemPrice]             DECIMAL (18, 2) NOT NULL,
    [TotalChargeAmount]     DECIMAL (18, 2) NOT NULL,
    [IPAddress]             NVARCHAR (MAX)  NULL,
    [CreatedUserID]         INT             NOT NULL,
    [LastModUserID]         INT             NOT NULL,
    [CreatedDate]           DATETIME        NOT NULL,
    [LastModDate]           DATETIME        NOT NULL,
    CONSTRAINT [PK_dbo.SalesContractWiseExtracharges] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

