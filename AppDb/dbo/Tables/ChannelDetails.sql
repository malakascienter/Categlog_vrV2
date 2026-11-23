CREATE TABLE [dbo].[ChannelDetails] (
    [ID]                         INT          IDENTITY (1, 1) NOT NULL,
    [ChannelCode]                VARCHAR (5)  NULL,
    [ChannelName]                VARCHAR (50) NULL,
    [OrderType]                  VARCHAR (1)  NULL,
    [DefaultPriceTypeId]         INT          NULL,
    [DefaultOutlet]              VARCHAR (5)  NULL,
    [Prifix]                     VARCHAR (3)  NULL,
    [AggregatorId]               INT          DEFAULT ((0)) NOT NULL,
    [IsAutoAcceptEnable]         BIT          DEFAULT ((0)) NOT NULL,
    [IsAutoDenyEnable]           BIT          DEFAULT ((0)) NOT NULL,
    [IsAutoCancelEnable]         BIT          DEFAULT ((0)) NOT NULL,
    [IsUpdatevButlerOrderStatus] BIT          CONSTRAINT [DF_ChannelDetails_IsUpdatevButlerOrderStatus] DEFAULT ((0)) NOT NULL
);


GO

