CREATE TABLE [dbo].[POS_BillChargeDetail] (
    [PropertyId]         INT             CONSTRAINT [DF_POS_BillChargeDetail_PropertyId] DEFAULT ((0)) NOT NULL,
    [BillChargeDetailID] BIGINT          NOT NULL,
    [OrderNo]            CHAR (6)        CONSTRAINT [DF_POS_BillChargeDetail_BillHeaderID] DEFAULT ('') NOT NULL,
    [OrderDate]          DATETIME        CONSTRAINT [DF_POS_BillChargeDetail_OrderDate] DEFAULT (getdate()) NOT NULL,
    [Outlet]             CHAR (3)        CONSTRAINT [DF_POS_BillChargeDetail_Outlet] DEFAULT ('') NOT NULL,
    [MenuItemID]         VARCHAR (10)    NOT NULL,
    [RefItemID]          VARCHAR (10)    NOT NULL,
    [ItemSequence]       INT             NOT NULL,
    [SortSeq]            INT             NOT NULL,
    [ChargeHeaderID]     INT             NOT NULL,
    [ChargeTypeID]       INT             NOT NULL,
    [ChargeTypeSequence] INT             CONSTRAINT [DF_POS_BillChargeDetail_ChargeTypeSequence] DEFAULT ((0)) NOT NULL,
    [ActualPercentage]   NUMERIC (18, 4) CONSTRAINT [DF_POS_BillChargeDetail_ActualPercentage] DEFAULT ((0)) NOT NULL,
    [ChargeAmount]       MONEY           CONSTRAINT [DF_Table_1_ActualPercentage1] DEFAULT ((0)) NOT NULL,
    [BrandID]            INT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_BillChargeDetail] PRIMARY KEY CLUSTERED ([PropertyId] ASC, [OrderNo] ASC, [OrderDate] ASC, [Outlet] ASC, [ItemSequence] ASC, [SortSeq] ASC, [ChargeTypeID] ASC)
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sub Total Percentage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_BillChargeDetail', @level2type = N'COLUMN', @level2name = N'ActualPercentage';


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sub Total Percentage', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_BillChargeDetail', @level2type = N'COLUMN', @level2name = N'ChargeAmount';


GO

