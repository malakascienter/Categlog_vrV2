CREATE TABLE [dbo].[LTY_SegmentWisePromotion] (
    [Id]          INT IDENTITY (1, 1) NOT NULL,
    [PropertyId]  INT NOT NULL,
    [PromotionId] INT NOT NULL,
    [SegmentId]   INT NOT NULL,
    CONSTRAINT [PK_LTY_SegmentWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_LTY_SegmentWisePromotion_Segment]
    ON [dbo].[LTY_SegmentWisePromotion]([SegmentId] ASC, [PropertyId] ASC);


GO

CREATE NONCLUSTERED INDEX [IX_LTY_SegmentWisePromotion_Promotion]
    ON [dbo].[LTY_SegmentWisePromotion]([PromotionId] ASC, [PropertyId] ASC)
    INCLUDE([SegmentId]);


GO

