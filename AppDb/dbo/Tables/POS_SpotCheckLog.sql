CREATE TABLE [dbo].[POS_SpotCheckLog] (
    [ID]                     BIGINT          IDENTITY (1, 1) NOT NULL,
    [SpotCheckNo]            BIGINT          CONSTRAINT [DF_POS_SpotCheckLog_SpotCheckNo] DEFAULT ((0)) NOT NULL,
    [Outlet]                 VARCHAR (5)     CONSTRAINT [DF_POS_SpotCheckLog_Outlet] DEFAULT ('') NOT NULL,
    [ShiftNo]                BIGINT          CONSTRAINT [DF_POS_SpotCheckLog_ShiftNo] DEFAULT ((0)) NOT NULL,
    [ShiftDate]              DATETIME        CONSTRAINT [DF_POS_SpotCheckLog_ShiftDate] DEFAULT (getdate()) NOT NULL,
    [StationID]              VARCHAR (250)   CONSTRAINT [DF_POS_SpotCheckLog_StationID] DEFAULT ('') NOT NULL,
    [CashireID]              VARCHAR (20)    NOT NULL,
    [PayTypeCode]            VARCHAR (10)    CONSTRAINT [DF_POS_SpotCheckLog_PayTypeCode] DEFAULT ('') NOT NULL,
    [IsCash]                 BIT             CONSTRAINT [DF_POS_SpotCheckLog_IsCash] DEFAULT ((0)) NOT NULL,
    [SystemAmount]           NUMERIC (18, 2) CONSTRAINT [DF_POS_SpotCheckLog_SystemAmount] DEFAULT ((0)) NOT NULL,
    [NoteType]               VARCHAR (50)    NOT NULL,
    [Nos]                    INT             NOT NULL,
    [Value]                  NUMERIC (18, 2) NOT NULL,
    [AuthorizedUser]         VARCHAR (50)    CONSTRAINT [DF_POS_SpotCheckLog_AuthorizedUser] DEFAULT ('') NOT NULL,
    [SysDate]                DATETIME        CONSTRAINT [DF_POS_SpotCheckLog_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsForeignCurrency]      BIT             CONSTRAINT [DF_POS_SpotCheckLog_IsForeignCurrency] DEFAULT ((0)) NOT NULL,
    [PropertyId]             INT             NOT NULL,
    [IsFirstApproval]        BIT             DEFAULT ((0)) NOT NULL,
    [IsSecondApproval]       BIT             DEFAULT ((0)) NOT NULL,
    [FirstApprovalRemark]    VARCHAR (200)   DEFAULT ('') NOT NULL,
    [SecondApprovalRemark]   VARCHAR (200)   DEFAULT ('') NOT NULL,
    [FirstApprovalUser]      INT             DEFAULT ((0)) NOT NULL,
    [FirstApprovalDateTime]  DATETIME        DEFAULT (getdate()) NOT NULL,
    [SecondApprovalUser]     INT             DEFAULT ((0)) NOT NULL,
    [SecondApprovalDateTime] DATETIME        DEFAULT (getdate()) NOT NULL
);


GO

