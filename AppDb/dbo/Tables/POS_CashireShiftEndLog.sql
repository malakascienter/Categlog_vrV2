CREATE TABLE [dbo].[POS_CashireShiftEndLog] (
    [ShiftNo]                VARCHAR (10)  NULL,
    [Cashireid]              VARCHAR (20)  NULL,
    [DType]                  VARCHAR (50)  NULL,
    [Nos]                    INT           NULL,
    [Value]                  MONEY         NULL,
    [SysDate]                DATETIME      CONSTRAINT [POS_DF_CashireShiftEndLog_sysdate] DEFAULT (getdate()) NOT NULL,
    [IsCash]                 BIT           CONSTRAINT [POS_DF_CashireShiftEndLog_IsCash] DEFAULT ((0)) NOT NULL,
    [Outlet]                 CHAR (3)      CONSTRAINT [POS_DF_CashireShiftEndLog_Outlet] DEFAULT ((1)) NOT NULL,
    [SystemAmount]           MONEY         CONSTRAINT [POS_DF_CashireShiftEndLog_SystemAmount] DEFAULT ((0)) NULL,
    [ShiftDate]              DATETIME      CONSTRAINT [POS_DF_CashireShiftEndLog_ShiftDate] DEFAULT (getdate()) NOT NULL,
    [PayTypeCode]            VARCHAR (10)  CONSTRAINT [POS_DF_CashireShiftEndLog_PayTypeCode] DEFAULT ('') NOT NULL,
    [IsForeignCurrency]      BIT           CONSTRAINT [POS_DF_CashireShiftEndLog_IsForeignCurrency] DEFAULT ((0)) NOT NULL,
    [PropertyId]             INT           NOT NULL,
    [IsFirstApproval]        BIT           DEFAULT ((0)) NOT NULL,
    [IsSecondApproval]       BIT           DEFAULT ((0)) NOT NULL,
    [FirstApprovalRemark]    VARCHAR (200) DEFAULT ('') NOT NULL,
    [SecondApprovalRemark]   VARCHAR (200) DEFAULT ('') NOT NULL,
    [FirstApprovalUser]      INT           DEFAULT ((0)) NOT NULL,
    [FirstApprovalDateTime]  DATETIME      DEFAULT (getdate()) NOT NULL,
    [SecondApprovalUser]     INT           DEFAULT ((0)) NOT NULL,
    [SecondApprovalDateTime] DATETIME      DEFAULT (getdate()) NOT NULL,
    [ID]                     BIGINT        IDENTITY (1, 1) NOT NULL
);


GO

