CREATE TABLE [dbo].[ItemPriceDetailsTemp] (
    [ID]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [ItemCode]        VARCHAR (10) NOT NULL,
    [SellingPrice]    MONEY        NOT NULL,
    [NewSellingPrice] MONEY        NOT NULL,
    [EffectFrom]      DATETIME     NOT NULL,
    [BatchID]         VARCHAR (10) NOT NULL,
    [PriceTypeId]     INT          NOT NULL,
    [PriceTypeName]   VARCHAR (50) NOT NULL,
    [SysDate]         DATETIME     DEFAULT (getdate()) NOT NULL,
    [PropertyId]      INT          DEFAULT ((0)) NOT NULL
);


GO

