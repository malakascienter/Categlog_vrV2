CREATE TABLE [dbo].[POS_EBillOrder] (
    [Id]                      INT           IDENTITY (1, 1) NOT NULL,
    [OrderNo]                 VARCHAR (6)   NOT NULL,
    [OrderDate]               DATETIME      NOT NULL,
    [Outlet]                  VARCHAR (3)   NOT NULL,
    [EmailAddress]            VARCHAR (500) NOT NULL,
    [IsEBillSend]             BIT           CONSTRAINT [DF_Table_1_IsSend] DEFAULT ((0)) NOT NULL,
    [IsEBillSendFail]         BIT           CONSTRAINT [DF_POS_EBillOrder_IsEBillSendFail] DEFAULT ((0)) NOT NULL,
    [EBillSendTime]           DATETIME      CONSTRAINT [DF_POS_EBillOrder_EBillSendTime] DEFAULT (getdate()) NOT NULL,
    [EBillsendFailTime]       DATETIME      CONSTRAINT [DF_POS_EBillOrder_EBillsendFailTime] DEFAULT (getdate()) NOT NULL,
    [SysDate]                 DATETIME      CONSTRAINT [DF_POS_EBillOrder_SysDate] DEFAULT (getdate()) NOT NULL,
    [PropertyId]              INT           DEFAULT ((0)) NOT NULL,
    [EmailAddressDisplayName] VARCHAR (MAX) DEFAULT ('') NOT NULL,
    [ContactNo]               VARCHAR (15)  DEFAULT ('') NOT NULL,
    [IsSMS]                   BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_EBillOrder] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

