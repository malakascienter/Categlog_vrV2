CREATE TABLE [dbo].[FinishFoodWastageDetails] (
    [PropertyID]   INT             CONSTRAINT [DF_FinishFoodWastageDetails_PropertyID] DEFAULT ((0)) NOT NULL,
    [LocationID]   INT             CONSTRAINT [DF_FinishFoodWastageDetails_LocationID] DEFAULT ((0)) NOT NULL,
    [OutletCode]   VARCHAR (3)     CONSTRAINT [DF_FinishFoodWastageDetails_LocationID1] DEFAULT ((0)) NOT NULL,
    [MenuCode]     VARCHAR (6)     CONSTRAINT [DF_FinishFoodWastageDetails_MenuCode] DEFAULT ('') NOT NULL,
    [StockItemID]  INT             CONSTRAINT [DF_FinishFoodWastageDetails_StockItemID] DEFAULT ((0)) NOT NULL,
    [Quantity]     DECIMAL (18, 8) CONSTRAINT [DF_FinishFoodWastageDetails_Quantity] DEFAULT ((0)) NOT NULL,
    [TxnUnitID]    INT             CONSTRAINT [DF_FinishFoodWastageDetails_TxnUnitID] DEFAULT ((0)) NOT NULL,
    [AveragePrice] NUMERIC (18, 8) CONSTRAINT [DF_FinishFoodWastageDetails_AveragePrice] DEFAULT ((0)) NOT NULL,
    [TxnDate]      DATETIME        CONSTRAINT [DF_FinishFoodWastageDetails_TxnUnitID1] DEFAULT (getdate()) NOT NULL,
    [Sysdate]      DATETIME        CONSTRAINT [DF_FinishFoodWastageDetails_Sysdate] DEFAULT (getdate()) NOT NULL,
    [DepartmentID] INT             NULL,
    [MenuItemQty]  MONEY           DEFAULT ((0)) NOT NULL,
    [MenuItemRate] MONEY           DEFAULT ((0)) NOT NULL,
    [DocumentNo]   VARCHAR (50)    DEFAULT ('') NOT NULL
);


GO

