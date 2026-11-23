CREATE TABLE [dbo].[PayTransCurrency] (
    [PropertyId]     INT             CONSTRAINT [DF_PayTransCurrency_PropertyId] DEFAULT ((0)) NOT NULL,
    [Outlet]         CHAR (3)        CONSTRAINT [DF_PayTransCurrency_Outlet] DEFAULT ('') NOT NULL,
    [OrderNo]        VARCHAR (10)    CONSTRAINT [DF_PayTransCurrency_OrderNo] DEFAULT ('') NOT NULL,
    [OrderDate]      DATETIME        CONSTRAINT [DF_PayTransCurrency_OrderDate] DEFAULT (getdate()) NOT NULL,
    [OrderType]      CHAR (2)        CONSTRAINT [DF_PayTransCurrency_OrderType] DEFAULT ('') NOT NULL,
    [PayType]        CHAR (2)        CONSTRAINT [DF_PayTransCurrency_PayType] DEFAULT ('') NOT NULL,
    [CurrCode]       VARCHAR (3)     CONSTRAINT [DF_PayTransCurrency_CurrCode] DEFAULT ('') NOT NULL,
    [ConversionRate] NUMERIC (18, 4) CONSTRAINT [DF_PayTransCurrency_ConversionRate] DEFAULT ((0)) NOT NULL,
    [CurrAmount]     NUMERIC (18, 4) CONSTRAINT [DF_Table_2_Value1] DEFAULT ((0)) NOT NULL,
    [TotalAmount]    NUMERIC (18, 4) CONSTRAINT [DF_Table_2_Amount] DEFAULT ((0)) NOT NULL,
    [ActualAmount]   NUMERIC (18, 4) CONSTRAINT [DF_PayTransCurrency_ActualAmount] DEFAULT ((0)) NOT NULL,
    [LocalCurr]      VARCHAR (3)     CONSTRAINT [DF_PayTransCurrency_BaseCurr] DEFAULT ('') NOT NULL,
    [LocalCurrRate]  NUMERIC (18, 4) CONSTRAINT [DF_PayTransCurrency_BaseCurrRate] DEFAULT ((0)) NOT NULL,
    [ShiftID]        BIGINT          CONSTRAINT [DF_PayTransCurrency_ShiftID] DEFAULT ((0)) NOT NULL
);


GO

