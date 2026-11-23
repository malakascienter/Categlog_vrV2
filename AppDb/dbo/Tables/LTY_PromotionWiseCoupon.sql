CREATE TABLE [dbo].[LTY_PromotionWiseCoupon] (
    [Id]             INT      IDENTITY (1, 1) NOT NULL,
    [PropertyId]     INT      NOT NULL,
    [PromotionId]    INT      NOT NULL,
    [ExipireDate]    DATETIME NOT NULL,
    [ExpireDayCount] INT      NULL,
    CONSTRAINT [PK_LTY_PromotionWiseCoupon] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

