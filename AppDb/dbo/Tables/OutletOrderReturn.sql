CREATE TABLE [dbo].[OutletOrderReturn] (
    [PropertyID]   INT             CONSTRAINT [DF_OutletOrderReturn_PropertyID] DEFAULT ((0)) NOT NULL,
    [LocationID]   INT             CONSTRAINT [DF_OutletOrderReturn_LocationID] DEFAULT ((0)) NOT NULL,
    [OutletCode]   VARCHAR (3)     CONSTRAINT [DF_OutletOrderReturn_LocationID1] DEFAULT ((0)) NOT NULL,
    [MenuCode]     VARCHAR (6)     CONSTRAINT [DF_OutletOrderReturn_MenuCode] DEFAULT ('') NOT NULL,
    [StockItemID]  INT             CONSTRAINT [DF_OutletOrderReturn_StockItemID] DEFAULT ((0)) NOT NULL,
    [Quantity]     DECIMAL (18, 8) CONSTRAINT [DF_OutletOrderReturn_Quantity] DEFAULT ((0)) NOT NULL,
    [TxnUnitID]    INT             CONSTRAINT [DF_OutletOrderReturn_TxnUnitID] DEFAULT ((0)) NOT NULL,
    [AveragePrice] NUMERIC (18, 8) CONSTRAINT [DF_OutletOrderReturn_AveragePrice] DEFAULT ((0)) NOT NULL,
    [TxnDate]      DATETIME        CONSTRAINT [DF_OutletOrderReturn_TxnUnitID1] DEFAULT (getdate()) NOT NULL,
    [Sysdate]      DATETIME        CONSTRAINT [DF_OutletOrderReturn_Sysdate] DEFAULT (getdate()) NOT NULL,
    [DepartmentID] INT             NULL,
    [MenuItemQty]  MONEY           DEFAULT ((0)) NOT NULL,
    [MenuItemRate] MONEY           DEFAULT ((0)) NOT NULL
);


GO

