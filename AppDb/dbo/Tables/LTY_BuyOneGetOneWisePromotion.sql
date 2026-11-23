CREATE TABLE [dbo].[LTY_BuyOneGetOneWisePromotion] (
    [Id]           INT             IDENTITY (1, 1) NOT NULL,
    [PropertyId]   INT             NOT NULL,
    [PromotionId]  INT             NOT NULL,
    [ItemCode]     VARCHAR (20)    NOT NULL,
    [FreeItemCode] VARCHAR (20)    NOT NULL,
    [FreeQty]      DECIMAL (18, 4) NULL,
    [MainItemQty]  DECIMAL (18, 4) NULL,
    CONSTRAINT [PK_LTY_BuyOneGetOneWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

