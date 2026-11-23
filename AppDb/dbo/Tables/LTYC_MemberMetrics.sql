CREATE TABLE [dbo].[LTYC_MemberMetrics] (
    [MemberId]            INT             NOT NULL,
    [PropertyId]          INT             NOT NULL,
    [LastPurchaseAt]      DATETIME2 (0)   NULL,
    [FirstPurchaseAt]     DATETIME2 (0)   NULL,
    [TransactionCount]    INT             CONSTRAINT [DF_LTYC_MemberMetrics_TxnCount] DEFAULT ((0)) NOT NULL,
    [TotalSpend]          DECIMAL (18, 4) CONSTRAINT [DF_LTYC_MemberMetrics_TotalSpend] DEFAULT ((0)) NOT NULL,
    [AvgTransactionValue] DECIMAL (18, 4) CONSTRAINT [DF_LTYC_MemberMetrics_AvgTxn] DEFAULT ((0)) NOT NULL,
    [LastOutletCode]      VARCHAR (50)    NULL,
    [PointBalance]        DECIMAL (18, 2) CONSTRAINT [DF_LTYC_MemberMetrics_Balance] DEFAULT ((0)) NOT NULL,
    [PointsEarned]        DECIMAL (18, 2) CONSTRAINT [DF_LTYC_MemberMetrics_Earned] DEFAULT ((0)) NOT NULL,
    [PointsRedeemed]      DECIMAL (18, 2) CONSTRAINT [DF_LTYC_MemberMetrics_Redeemed] DEFAULT ((0)) NOT NULL,
    [PointsExpired]       DECIMAL (18, 2) CONSTRAINT [DF_LTYC_MemberMetrics_Expired] DEFAULT ((0)) NOT NULL,
    [PointsExpiring30d]   DECIMAL (18, 2) CONSTRAINT [DF_LTYC_MemberMetrics_Expiring] DEFAULT ((0)) NOT NULL,
    [VouchersIssued]      INT             CONSTRAINT [DF_LTYC_MemberMetrics_VIssued] DEFAULT ((0)) NOT NULL,
    [VouchersRedeemed]    INT             CONSTRAINT [DF_LTYC_MemberMetrics_VRedeemed] DEFAULT ((0)) NOT NULL,
    [VouchersUnused]      INT             CONSTRAINT [DF_LTYC_MemberMetrics_VUnused] DEFAULT ((0)) NOT NULL,
    [LastRedemptionAt]    DATETIME2 (0)   NULL,
    [ComputedAt]          DATETIME2 (0)   CONSTRAINT [DF_LTYC_MemberMetrics_ComputedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYC_MemberMetrics] PRIMARY KEY CLUSTERED ([MemberId] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_MemberMetrics_PointBalance]
    ON [dbo].[LTYC_MemberMetrics]([PropertyId] ASC, [PointBalance] ASC)
    INCLUDE([MemberId], [LastPurchaseAt]);


GO

CREATE NONCLUSTERED INDEX [IX_LTYC_MemberMetrics_LastPurchase]
    ON [dbo].[LTYC_MemberMetrics]([PropertyId] ASC, [LastPurchaseAt] ASC)
    INCLUDE([MemberId], [PointBalance], [TotalSpend]);


GO

