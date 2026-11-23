CREATE TABLE [dbo].[LTY_ItemWisePromotion] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [PropertyId]  INT          NOT NULL,
    [PromotionId] INT          NOT NULL,
    [ItemId]      VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_LTY_ItemWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

