CREATE TABLE [dbo].[LTY_LocationWisePromotion] (
    [Id]           INT          IDENTITY (1, 1) NOT NULL,
    [PromotionId]  INT          NOT NULL,
    [LocationCode] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_LTY_LocationWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

