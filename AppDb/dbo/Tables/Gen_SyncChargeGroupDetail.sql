CREATE TABLE [dbo].[Gen_SyncChargeGroupDetail] (
    [PropertyID]         INT             CONSTRAINT [DF_Gen_SyncChargeGroupDetail_PropertyID] DEFAULT ((0)) NOT NULL,
    [ChargeDetailID]     INT             NOT NULL,
    [ChargeHeaderID]     INT             NOT NULL,
    [ChargeTypeID]       INT             NOT NULL,
    [ActualPercentage]   NUMERIC (18, 8) CONSTRAINT [DF_Gen_SyncChargeGroupDetail_ActualPercentage] DEFAULT ((0)) NOT NULL,
    [ChargeTypeSequence] INT             CONSTRAINT [DF_Gen_SyncChargeGroupDetail_ChargeTypeSequence] DEFAULT ((0)) NOT NULL
);


GO

