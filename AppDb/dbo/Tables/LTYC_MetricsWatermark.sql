CREATE TABLE [dbo].[LTYC_MetricsWatermark] (
    [PropertyId]        INT           NOT NULL,
    [LastPointTransId]  INT           CONSTRAINT [DF_LTYC_MetricsWatermark_Txn] DEFAULT ((0)) NOT NULL,
    [LastCouponId]      INT           CONSTRAINT [DF_LTYC_MetricsWatermark_Coupon] DEFAULT ((0)) NOT NULL,
    [LastCouponUsageId] INT           CONSTRAINT [DF_LTYC_MetricsWatermark_Usage] DEFAULT ((0)) NOT NULL,
    [LastFullRebuildAt] DATETIME2 (0) NULL,
    [LastRunAt]         DATETIME2 (0) NULL,
    CONSTRAINT [PK_LTYC_MetricsWatermark] PRIMARY KEY CLUSTERED ([PropertyId] ASC)
);


GO

