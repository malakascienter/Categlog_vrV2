CREATE TABLE [dbo].[POS_CashSkim] (
    [PropertyId]   INT             NOT NULL,
    [ID]           BIGINT          NOT NULL,
    [SkimNo]       BIGINT          CONSTRAINT [DF_POS_CashSkim_SkimNo] DEFAULT ((0)) NOT NULL,
    [ShiftNo]      INT             CONSTRAINT [DF_POS_CashSkim_ShiftNo] DEFAULT ((0)) NOT NULL,
    [ShiftDate]    DATETIME        CONSTRAINT [DF_POS_CashSkim_ShiftDate] DEFAULT (getdate()) NOT NULL,
    [CashireId]    VARCHAR (20)    CONSTRAINT [DF_POS_CashSkim_CashireId] DEFAULT ('') NOT NULL,
    [Outlet]       VARCHAR (3)     CONSTRAINT [DF_POS_CashSkim_Outlet] DEFAULT ((1)) NOT NULL,
    [StationID]    VARCHAR (50)    CONSTRAINT [DF_POS_CashSkim_StationID] DEFAULT ((0)) NOT NULL,
    [CurrencyType] VARCHAR (50)    CONSTRAINT [DF_POS_CashSkim_CurrencyType] DEFAULT ('') NOT NULL,
    [Nos]          INT             CONSTRAINT [DF_POS_CashSkim_Nos] DEFAULT ((0)) NOT NULL,
    [Value]        NUMERIC (18, 2) CONSTRAINT [DF_POS_CashSkim_Value] DEFAULT ((0)) NOT NULL,
    [SysDate]      DATETIME        CONSTRAINT [DF_Table_1_sysdate] DEFAULT (getdate()) NOT NULL
);


GO

