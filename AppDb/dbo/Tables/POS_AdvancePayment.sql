CREATE TABLE [dbo].[POS_AdvancePayment] (
    [ID]             BIGINT          NOT NULL,
    [DocNo]          VARCHAR (15)    CONSTRAINT [DF_Table_2_OrderNo] DEFAULT ('') NOT NULL,
    [DocTypeID]      TINYINT         CONSTRAINT [DF_POS_AdvancePayment_DocTypeID] DEFAULT ((0)) NOT NULL,
    [DocDate]        DATETIME        CONSTRAINT [DF_Table_2_OrderDate] DEFAULT (getdate()) NOT NULL,
    [PayCode]        VARCHAR (3)     CONSTRAINT [DF_POS_AdvancePayment_PayCode] DEFAULT ('') NOT NULL,
    [TenderedAmount] NUMERIC (18, 2) CONSTRAINT [DF_POS_AdvancePayment_TenderedAmount] DEFAULT ((0)) NOT NULL,
    [ActualAmount]   NUMERIC (18, 2) CONSTRAINT [DF_Table_2_OrderAmount] DEFAULT ((0)) NOT NULL,
    [OutletCode]     VARCHAR (5)     CONSTRAINT [DF_POS_AdvancePayment_OutletCode] DEFAULT ('') NOT NULL,
    [UserName]       VARCHAR (20)    CONSTRAINT [DF_POS_AdvancePayment_UserName] DEFAULT ('') NOT NULL,
    [Remarks]        VARCHAR (250)   CONSTRAINT [DF_POS_AdvancePayment_Remarks] DEFAULT ('') NOT NULL,
    [SysDate]        DATETIME        CONSTRAINT [DF_POS_AdvancePayment_SysDate] DEFAULT (getdate()) NOT NULL,
    [PropertyId]     INT             CONSTRAINT [DF_POS_AdvancePayment_PropertyId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_AdvancePayment] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

