CREATE TABLE [dbo].[VoidPayTrans] (
    [PropertyId]         INT             CONSTRAINT [DF_VoidPayTrans_PropertyId] DEFAULT ((0)) NOT NULL,
    [OrderNo]            CHAR (6)        NOT NULL,
    [OrderDate]          DATETIME        NOT NULL,
    [PayCode]            CHAR (2)        NOT NULL,
    [Total]              MONEY           CONSTRAINT [DF_VoidPayTrans_Total_1] DEFAULT ((0)) NOT NULL,
    [Tendered]           MONEY           CONSTRAINT [DF_VoidPayTrans_Tendered_1] DEFAULT ((0)) NOT NULL,
    [ActualAmt]          MONEY           CONSTRAINT [DF_VoidPayTrans_ActualAmt_1] DEFAULT ((0)) NOT NULL,
    [Remark]             VARCHAR (30)    CONSTRAINT [DF_VoidPayTrans_Remark_1] DEFAULT (' ') NOT NULL,
    [UserID]             VARCHAR (20)    CONSTRAINT [DF_VoidPayTrans_UserID_1] DEFAULT (' ') NOT NULL,
    [OrderTime]          DATETIME        NULL,
    [Outlet]             CHAR (3)        NOT NULL,
    [pin]                VARCHAR (10)    NULL,
    [compcode]           CHAR (3)        NULL,
    [ShiftID]            BIGINT          CONSTRAINT [DF_VoidPayTrans_ShiftID_1] DEFAULT ((0)) NOT NULL,
    [RoundingDifference] NUMERIC (18, 6) CONSTRAINT [DF_VoidPayTrans_RoundingDifference] DEFAULT ((0)) NOT NULL
);


GO

