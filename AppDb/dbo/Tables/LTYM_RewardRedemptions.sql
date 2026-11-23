CREATE TABLE [dbo].[LTYM_RewardRedemptions] (
    [Id]           BIGINT          IDENTITY (1, 1) NOT NULL,
    [RewardId]     INT             NOT NULL,
    [MemberId]     INT             NOT NULL,
    [CouponId]     INT             NOT NULL,
    [PointTransId] INT             NOT NULL,
    [PointsSpent]  DECIMAL (18, 2) NOT NULL,
    [CouponCode]   VARCHAR (50)    NOT NULL,
    [CreatedAt]    DATETIME2 (0)   CONSTRAINT [DF_LTYM_RewardRedemptions_CreatedAt] DEFAULT (sysutcdatetime()) NOT NULL,
    CONSTRAINT [PK_LTYM_RewardRedemptions] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTYM_RewardRedemptions_Member]
    ON [dbo].[LTYM_RewardRedemptions]([MemberId] ASC, [Id] ASC);


GO

