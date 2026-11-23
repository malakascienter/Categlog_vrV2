CREATE TABLE [dbo].[LTYJ_RunVoucher] (
    [RunVoucherId] BIGINT        IDENTITY (1, 1) NOT NULL,
    [RunId]        BIGINT        NOT NULL,
    [JourneyId]    INT           NOT NULL,
    [MemberId]     INT           NOT NULL,
    [PropertyId]   INT           NOT NULL,
    [CouponId]     INT           NOT NULL,
    [VoucherRef]   VARCHAR (50)  NOT NULL,
    [NodeKey]      VARCHAR (50)  NOT NULL,
    [IssuedAt]     DATETIME2 (3) CONSTRAINT [DF_LTYJ_RunVoucher_IssuedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    [UsedAt]       DATETIME2 (3) NULL,
    CONSTRAINT [PK_LTYJ_RunVoucher] PRIMARY KEY CLUSTERED ([RunVoucherId] ASC),
    CONSTRAINT [UQ_LTYJ_RunVoucher_Run_Ref] UNIQUE NONCLUSTERED ([RunId] ASC, [VoucherRef] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_RunVoucher_Journey]
    ON [dbo].[LTYJ_RunVoucher]([JourneyId] ASC, [IssuedAt] ASC)
    INCLUDE([CouponId], [UsedAt], [NodeKey]);


GO

CREATE NONCLUSTERED INDEX [IX_LTYJ_RunVoucher_Coupon]
    ON [dbo].[LTYJ_RunVoucher]([CouponId] ASC)
    INCLUDE([RunId], [JourneyId], [MemberId], [VoucherRef], [UsedAt]);


GO

