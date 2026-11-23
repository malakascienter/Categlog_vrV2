CREATE TABLE [dbo].[POS_CashierShift] (
    [ShiftNo]              INT             CONSTRAINT [DF_CashierShift_ShiftNo] DEFAULT ((0)) NOT NULL,
    [ShiftDate]            DATETIME        CONSTRAINT [DF_CashierShift_ShiftDate] DEFAULT (getdate()) NOT NULL,
    [WaiterCode]           VARCHAR (8)     CONSTRAINT [DF_CashierShift_WaiterCode] DEFAULT ('') NOT NULL,
    [IsSignOff]            BIT             CONSTRAINT [DF_CashierShift_IsSignOff] DEFAULT ((0)) NOT NULL,
    [CashFloat]            NUMERIC (18, 4) CONSTRAINT [DF_CashierShift_CashFloat] DEFAULT ((4)) NOT NULL,
    [SignOffDate]          DATETIME        CONSTRAINT [DF_POS_CashierShift_ShiftDate1] DEFAULT (getdate()) NOT NULL,
    [StationID]            VARCHAR (50)    CONSTRAINT [DF_POS_CashierShift_StationID] DEFAULT ((0)) NOT NULL,
    [Outlet]               CHAR (3)        CONSTRAINT [DF_POS_CashierShift_Outlet] DEFAULT ((1)) NOT NULL,
    [PropertyId]           INT             NOT NULL,
    [IsManagerSignOff]     BIT             DEFAULT ((0)) NOT NULL,
    [SignOnDate]           DATE            DEFAULT (getdate()) NOT NULL,
    [SignOnAuthorizedUser] VARCHAR (100)   DEFAULT ('') NOT NULL,
    [SignOffTime]          DATETIME        CONSTRAINT [DF_POS_CashierShift_SignOffTime] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CashierShift] PRIMARY KEY CLUSTERED ([ShiftNo] ASC, [WaiterCode] ASC)
);


GO

