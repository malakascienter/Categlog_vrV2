CREATE TABLE [dbo].[LTY_PaymentTypeWisePromotion] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [PromotionId]     INT          NOT NULL,
    [PaymentTypeCode] VARCHAR (20) NOT NULL,
    CONSTRAINT [PK_LTY_PaymentTypeWisePromotion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

