CREATE TABLE [dbo].[Gen_ItemChargeGroupDetail] (
    [ID]                 SMALLINT    CONSTRAINT [DF_Gen_ItemChargeGroupDetail_ID] DEFAULT ((0)) NOT NULL,
    [ItemChargeHeaderID] SMALLINT    CONSTRAINT [DF_Gen_ItemChargeGroupDetail_HeaderID] DEFAULT ((0)) NOT NULL,
    [OrderType]          VARCHAR (1) CONSTRAINT [DF_Table_1_OrderTypeID] DEFAULT ((0)) NOT NULL,
    [ChargeHeaderID]     INT         NOT NULL
);


GO

