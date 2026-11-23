CREATE TABLE [dbo].[POS_BillOpenMenu] (
    [PropertyId]   INT             CONSTRAINT [DF_POS_BillOpenMenu_PropertyId] DEFAULT ((0)) NOT NULL,
    [OrderNo]      VARCHAR (6)     CONSTRAINT [DF_POS_BillOpenMenu_OrderNo] DEFAULT ('') NOT NULL,
    [OrderDate]    DATETIME        CONSTRAINT [DF_POS_BillOpenMenu_OrderDate] DEFAULT (getdate()) NOT NULL,
    [Outlet]       VARCHAR (3)     CONSTRAINT [DF_POS_BillOpenMenu_Outlet] DEFAULT ('') NOT NULL,
    [MenuItemID]   VARCHAR (4)     CONSTRAINT [DF_POS_BillOpenMenu_MenuItemID] DEFAULT ('') NOT NULL,
    [MenuName]     VARCHAR (50)    CONSTRAINT [DF_POS_BillOpenMenu_MenuName] DEFAULT ('') NOT NULL,
    [Rate]         NUMERIC (18, 2) CONSTRAINT [DF_POS_BillOpenMenu_Rate] DEFAULT ((0)) NOT NULL,
    [Quantity]     NUMERIC (18, 2) CONSTRAINT [DF_POS_BillOpenMenu_Rate1] DEFAULT ((0)) NOT NULL,
    [ItemSequence] INT             CONSTRAINT [DF_POS_BillOpenMenu_ItemSequence] DEFAULT ((0)) NOT NULL,
    [SortSeq]      INT             CONSTRAINT [DF_POS_BillOpenMenu_SortSeq] DEFAULT ((0)) NOT NULL
);


GO

