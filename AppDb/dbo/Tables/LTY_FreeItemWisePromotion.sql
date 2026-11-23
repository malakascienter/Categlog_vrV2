CREATE TABLE [dbo].[LTY_FreeItemWisePromotion] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]  INT             NOT NULL,
    [PromotionId] INT             NOT NULL,
    [ItemId]      VARCHAR (20)    NOT NULL,
    [FreeQty]     DECIMAL (18, 4) NULL,
    CONSTRAINT [PK_LTY_FreeItemWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

