CREATE TABLE [dbo].[ProductionRequestDetails] (
    [ID]          INT         IDENTITY (1, 1) NOT NULL,
    [PRHeaderID]  INT         NULL,
    [ItemID]      INT         NULL,
    [UnitID]      INT         NULL,
    [Remarks]     NCHAR (500) NULL,
    [ApprovedQTY] MONEY       CONSTRAINT [DF_ProductionRequestDetails_ApprovedQTY] DEFAULT ((0)) NOT NULL,
    [AdjustedQty] MONEY       CONSTRAINT [DF_ProductionRequestDetails_AdjustedQty] DEFAULT ((0)) NOT NULL,
    [ProducedQTY] MONEY       CONSTRAINT [DF_ProductionRequestDetails_ProducedQTY] DEFAULT ((0)) NOT NULL,
    [BalanceQTY]  MONEY       CONSTRAINT [DF_ProductionRequestDetails_BalanceQTY] DEFAULT ((0)) NOT NULL,
    [Status]      VARCHAR (5) NULL,
    [LogDate]     DATETIME    CONSTRAINT [DF__Productio__LogDa__0DDF849A] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProductionRequestDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

