CREATE TABLE [dbo].[Gen_ItemChargeGroupHeader] (
    [ItemChargeHeaderID]   SMALLINT     CONSTRAINT [DF_Gen_ItemChargeGroupHeader_ID] DEFAULT ((0)) NOT NULL,
    [ItemChargeHeaderName] VARCHAR (30) CONSTRAINT [DF_Gen_ItemChargeGroupHeader_Name] DEFAULT ('') NOT NULL
);


GO

