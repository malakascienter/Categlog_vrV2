CREATE TABLE [dbo].[LTY_TierWisePromotion] (
    [Id]          INT IDENTITY (1, 1) NOT NULL,
    [PromotionId] INT NOT NULL,
    [TierId]      INT NOT NULL,
    CONSTRAINT [PK_LTY_TierWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

