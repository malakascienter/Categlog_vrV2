CREATE TABLE [dbo].[POS_MaaluOutletConfig] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [PropertyId]          INT           NOT NULL,
    [OutletCode]          VARCHAR (5)   NOT NULL,
    [Maalu_StoreId]       VARCHAR (200) NOT NULL,
    [Maalu_ChannelCode]   VARCHAR (50)  NULL,
    [Maaluclient_id]      VARCHAR (500) NULL,
    [Maaluclient_secret]  VARCHAR (500) NULL,
    [MaaluAggregatorType] VARCHAR (50)  NULL,
    [IsMaaluEnabled]      BIT           CONSTRAINT [DF_POS_MaaluOutletConfig_IsMaaluEnabled] DEFAULT ((1)) NOT NULL,
    [SysDate]             DATETIME      CONSTRAINT [DF_POS_MaaluOutletConfig_SysDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_POS_MaaluOutletConfig] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE UNIQUE NONCLUSTERED INDEX [UX_POS_MaaluOutletConfig_StoreId]
    ON [dbo].[POS_MaaluOutletConfig]([Maalu_StoreId] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_POS_MaaluOutletConfig_Outlet]
    ON [dbo].[POS_MaaluOutletConfig]([PropertyId] ASC, [OutletCode] ASC);


GO

