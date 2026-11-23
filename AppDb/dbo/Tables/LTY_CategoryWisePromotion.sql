CREATE TABLE [dbo].[LTY_CategoryWisePromotion] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [PropertyId]  INT          NOT NULL,
    [PromotionId] INT          NOT NULL,
    [CategoryId]  VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_LTY_CategoryWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

