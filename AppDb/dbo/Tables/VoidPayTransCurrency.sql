CREATE TABLE [dbo].[VoidPayTransCurrency] (
    [PropertyId]     INT             CONSTRAINT [DF_VoidPayTransCurrency_PropertyId] DEFAULT ((0)) NOT NULL,
    [Outlet]         VARCHAR (10)    CONSTRAINT [DF_VoidPayTransCurrency_Outlet] DEFAULT ('') NOT NULL,
    [OrderNo]        CHAR (6)        CONSTRAINT [DF_VoidPayTransCurrency_OrderNo] DEFAULT ('') NOT NULL,
    [OrderDate]      DATETIME        CONSTRAINT [DF_VoidPayTransCurrency_OrderDate] DEFAULT (getdate()) NOT NULL,
    [OrderType]      CHAR (2)        CONSTRAINT [DF_VoidPayTransCurrency_OrderType] DEFAULT ('') NOT NULL,
    [PayType]        CHAR (2)        CONSTRAINT [DF_VoidPayTransCurrency_PayType] DEFAULT ('') NOT NULL,
    [CurrCode]       VARCHAR (3)     CONSTRAINT [DF_VoidPayTransCurrency_CurrCode] DEFAULT ('') NOT NULL,
    [ConversionRate] NUMERIC (18, 4) CONSTRAINT [DF_VoidPayTransCurrency_ConversionRate] DEFAULT ((0)) NOT NULL,
    [CurrAmount]     NUMERIC (18, 4) CONSTRAINT [DF_VoidPayTransCurrency_CurrAmount] DEFAULT ((0)) NOT NULL,
    [TotalAmount]    NUMERIC (18, 4) CONSTRAINT [DF_VoidPayTransCurrency_TotalAmount] DEFAULT ((0)) NOT NULL,
    [ActualAmount]   NUMERIC (18, 4) CONSTRAINT [DF_VoidPayTransCurrency_ActualAmount] DEFAULT ((0)) NOT NULL,
    [LocalCurr]      VARCHAR (3)     CONSTRAINT [DF_VoidPayTransCurrency_BaseCurr] DEFAULT ('') NOT NULL,
    [LocalCurrRate]  NUMERIC (18, 4) CONSTRAINT [DF_VoidPayTransCurrency_BaseCurrRate] DEFAULT ((0)) NOT NULL,
    [ShiftID]        BIGINT          CONSTRAINT [DF_VoidPayTransCurrency_ShiftID] DEFAULT ((0)) NOT NULL
);


GO

