CREATE TABLE [dbo].[LTY_DayWisePromotion] (
    [Id]          INT          IDENTITY (1, 1) NOT NULL,
    [PromotionId] INT          NOT NULL,
    [Days]        VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_LTY_DayWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

