CREATE TABLE [dbo].[PayTrans] (
    [ID]                 INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]         INT             CONSTRAINT [DF_PayTrans_PropertyId] DEFAULT ((0)) NOT NULL,
    [OrderNo]            CHAR (6)        NOT NULL,
    [OrderDate]          DATETIME        NOT NULL,
    [PayCode]            CHAR (2)        NOT NULL,
    [Total]              MONEY           CONSTRAINT [DF_PayTrans_Total] DEFAULT ((0)) NOT NULL,
    [Tendered]           MONEY           CONSTRAINT [DF_PayTrans_Tendered] DEFAULT ((0)) NOT NULL,
    [ActualAmt]          MONEY           CONSTRAINT [DF_PayTrans_ActualAmt] DEFAULT ((0)) NOT NULL,
    [Remark]             VARCHAR (30)    CONSTRAINT [DF_PayTrans_Remark] DEFAULT (' ') NOT NULL,
    [UserID]             VARCHAR (20)    CONSTRAINT [DF_PayTrans_UserID] DEFAULT (' ') NOT NULL,
    [OrderTime]          DATETIME        NULL,
    [Outlet]             CHAR (3)        NOT NULL,
    [pin]                VARCHAR (10)    NULL,
    [compcode]           CHAR (3)        NULL,
    [ShiftID]            BIGINT          CONSTRAINT [DF_PayTrans_ShiftID_1] DEFAULT ((0)) NOT NULL,
    [RoundingDifference] NUMERIC (18, 6) CONSTRAINT [DF_PayTrans_RoundingDifference] DEFAULT ((0)) NOT NULL,
    [SyncDateTime]       DATETIME        CONSTRAINT [DF_PayTrans_SyncDateTime] DEFAULT (getdate()) NOT NULL
);


GO

