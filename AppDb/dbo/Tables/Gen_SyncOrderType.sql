CREATE TABLE [dbo].[Gen_SyncOrderType] (
    [ID]             INT         CONSTRAINT [DF_Gen_SyncOrderType_ID] DEFAULT ((0)) NOT NULL,
    [PropertyID]     INT         CONSTRAINT [DF_Gen_SyncOrderType_PropertyID] DEFAULT ((0)) NOT NULL,
    [OrderType]      VARCHAR (5) CONSTRAINT [DF_Gen_SyncOrderType_OrderType] DEFAULT ('') NOT NULL,
    [ChargeHeaderID] INT         CONSTRAINT [DF_Gen_SyncOrderType_ChargeHeaderID] DEFAULT ((0)) NOT NULL
);


GO

