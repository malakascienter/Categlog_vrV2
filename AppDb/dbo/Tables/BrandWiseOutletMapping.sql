CREATE TABLE [dbo].[BrandWiseOutletMapping] (
    [Code]                  NVARCHAR (50)  NULL,
    [IPAddress]             NVARCHAR (50)  NULL,
    [Description]           NVARCHAR (255) NULL,
    [Active]                INT            NULL,
    [PropertyId]            INT            NULL,
    [BrandID]               INT            NULL,
    [UberEatStoresURL]      NVARCHAR (500) NULL,
    [UberEatclient_id]      NVARCHAR (200) NULL,
    [UberEatclient_secret]  NVARCHAR (200) NULL,
    [UberEatAggregatorType] NVARCHAR (50)  NULL,
    [CurrentDate]           DATETIME       NULL,
    [CurrentDateStr]        VARCHAR (10)   NULL,
    [UberEat_StoreId]       NVARCHAR (100) NULL,
    [OutletDatabase]        NVARCHAR (100) NULL,
    [OutletServer]          NVARCHAR (100) NULL,
    [OutletServerPassword]  NVARCHAR (100) NULL,
    [OutletServerUsername]  NVARCHAR (100) NULL,
    [IPAddressALT]          VARCHAR (MAX)  DEFAULT ('') NOT NULL,
    [UberEat_ChannelCode]   VARCHAR (MAX)  DEFAULT ('') NOT NULL,
    [Id]                    INT            IDENTITY (1, 1) NOT NULL,
    [BadaginiApiKey]        VARCHAR (MAX)  NULL,
    [PickMe_ApiKey]         VARCHAR (500)  NULL,
    [Maalu_StoreId]         VARCHAR (200)  NULL
);


GO

