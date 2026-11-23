CREATE TABLE [dbo].[OutletKitchenIssues] (
    [PropertyID]   INT             CONSTRAINT [DF_OutletKitchenIssues_PropertyID] DEFAULT ((0)) NOT NULL,
    [LocationID]   INT             CONSTRAINT [DF_OutletKitchenIssues_LocationID] DEFAULT ((0)) NOT NULL,
    [OutletCode]   VARCHAR (3)     CONSTRAINT [DF_Table_1_LocationID1] DEFAULT ((0)) NOT NULL,
    [MenuCode]     VARCHAR (6)     CONSTRAINT [DF_OutletKitchenIssues_MenuCode] DEFAULT ('') NOT NULL,
    [StockItemID]  INT             CONSTRAINT [DF_OutletKitchenIssues_StockItemID] DEFAULT ((0)) NOT NULL,
    [Quantity]     DECIMAL (18, 8) CONSTRAINT [DF_OutletKitchenIssues_Quantity] DEFAULT ((0)) NOT NULL,
    [TxnUnitID]    INT             CONSTRAINT [DF_OutletKitchenIssues_TxnUnitID] DEFAULT ((0)) NOT NULL,
    [AveragePrice] NUMERIC (18, 8) CONSTRAINT [DF_OutletKitchenIssues_AveragePrice] DEFAULT ((0)) NOT NULL,
    [TxnDate]      DATETIME        CONSTRAINT [DF_Table_1_TxnUnitID1] DEFAULT (getdate()) NOT NULL,
    [Sysdate]      DATETIME        CONSTRAINT [DF_OutletKitchenIssues_Sysdate] DEFAULT (getdate()) NOT NULL,
    [DepartmentID] INT             NULL,
    [MenuItemQty]  MONEY           DEFAULT ((0)) NOT NULL,
    [MenuItemRate] MONEY           DEFAULT ((0)) NOT NULL
);


GO

