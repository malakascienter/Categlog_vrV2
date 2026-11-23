CREATE TABLE [dbo].[POS_KotBot] (
    [PropertyId]     INT           CONSTRAINT [DF_POS_KotBot_PropertyId] DEFAULT ((0)) NOT NULL,
    [KotBotNo]       VARCHAR (10)  CONSTRAINT [DF_POS_KotBot_KotBotNo] DEFAULT ('') NOT NULL,
    [KotBotDateTime] SMALLDATETIME CONSTRAINT [DF_Table_2_OrderDate1] DEFAULT (getdate()) NOT NULL,
    [OrderNo]        VARCHAR (10)  NOT NULL,
    [OrderDate]      SMALLDATETIME CONSTRAINT [DF_Table_2_OrderDateTime] DEFAULT (getdate()) NOT NULL,
    [OrderType]      VARCHAR (1)   CONSTRAINT [DF_POS_KotBot_OrderType] DEFAULT ('') NOT NULL,
    [TableID]        INT           CONSTRAINT [DF_POS_KotBot_TableID] DEFAULT ((0)) NOT NULL,
    [WaiterID]       VARCHAR (10)  CONSTRAINT [DF_POS_KotBot_WaiterID] DEFAULT ('') NOT NULL,
    [OutletID]       VARCHAR (10)  NOT NULL,
    [PrinterCode]    VARCHAR (2)   CONSTRAINT [DF_POS_KotBot_PrinterCode] DEFAULT ('') NOT NULL,
    [MenuItemID]     VARCHAR (10)  NOT NULL,
    [KOTName]        VARCHAR (250) NOT NULL,
    [KOTQuantity]    MONEY         CONSTRAINT [DF_POS_KotBot_KOTQuantity] DEFAULT ((0)) NOT NULL,
    [VoidQuantity]   MONEY         CONSTRAINT [DF_POS_KotBot_KOTQuantity1] DEFAULT ((0)) NOT NULL,
    [ItemSequence]   INT           CONSTRAINT [DF_POS_KotBot_ItemSequence] DEFAULT ((0)) NOT NULL,
    [SortSeq]        INT           CONSTRAINT [DF_POS_KotBot_SortSeq] DEFAULT ((0)) NOT NULL,
    [IsVoid]         BIT           CONSTRAINT [DF_POS_KotBot_IsVoid] DEFAULT ((0)) NOT NULL,
    [VoidDateTime]   DATETIME      NULL,
    [AuthorizedUser] VARCHAR (20)  CONSTRAINT [DF_POS_KotBot_AuthorizedUser] DEFAULT ('') NOT NULL,
    [SysDate]        SMALLDATETIME CONSTRAINT [DF_POS_KotBot_KotBotDateTime1] DEFAULT (getdate()) NOT NULL,
    [IsServe]        BIT           CONSTRAINT [DF__POS_KotBo__IsSer__700A6687] DEFAULT ((0)) NOT NULL,
    [ServeTime]      DATETIME      NULL
);


GO

CREATE NONCLUSTERED INDEX [Index_POS_KotBot_OrderNo_OrderDate_OutletID_MenuItemID_ItemSequence_SortSeq]
    ON [dbo].[POS_KotBot]([PropertyId] ASC, [OrderNo] ASC, [OrderDate] ASC, [OutletID] ASC, [MenuItemID] ASC, [ItemSequence] ASC, [SortSeq] ASC)
    INCLUDE([KOTName]);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Add on 2020-01-30', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_KotBot', @level2type = N'COLUMN', @level2name = N'SysDate';


GO

