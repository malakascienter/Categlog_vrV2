CREATE TABLE [dbo].[POS_LoyaltyPoint] (
    [PayType]     VARCHAR (5)     CONSTRAINT [DF__POS_Loyal__PayTy__389B0163] DEFAULT ('') NOT NULL,
    [PointValue]  NUMERIC (18, 2) CONSTRAINT [DF__POS_Loyal__Point__08CBF2B0] DEFAULT ((0)) NOT NULL,
    [EarnValue]   NUMERIC (18, 4) CONSTRAINT [DF_Table_2_PointValue1] DEFAULT ((0)) NOT NULL,
    [RedeemValue] NUMERIC (18, 4) NOT NULL
);


GO

