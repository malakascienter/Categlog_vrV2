CREATE TABLE [dbo].[Gen_SyncChargeGroupHeader] (
    [PropertyID]     INT             CONSTRAINT [DF_Gen_SyncChargeGroupHeader_PropertyID] DEFAULT ((0)) NOT NULL,
    [ChargeHeaderID] INT             CONSTRAINT [DF_Gen_SyncChargeGroupHeader_ChargeHeaderID] DEFAULT ((0)) NOT NULL,
    [Name]           VARCHAR (30)    CONSTRAINT [DF_Gen_SyncChargeGroupHeader_Name] DEFAULT ('') NOT NULL,
    [ResNetVal]      NUMERIC (18, 8) CONSTRAINT [DF_Gen_SyncChargeGroupHeader_ResNetVal] DEFAULT ((0)) NOT NULL
);


GO

