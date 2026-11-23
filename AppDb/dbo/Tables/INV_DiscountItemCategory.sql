CREATE TABLE [dbo].[INV_DiscountItemCategory] (
    [Id]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [DiscountId]      INT          NOT NULL,
    [DiscountCode]    VARCHAR (10) NOT NULL,
    [CategoryCode]    VARCHAR (50) NOT NULL,
    [PropertyId]      INT          NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     CONSTRAINT [DF_INV_DiscountItemCategory_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_INV_DiscountItemCategory] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_INV_DiscountItemCategory_Discount]
    ON [dbo].[INV_DiscountItemCategory]([DiscountId] ASC, [PropertyId] ASC)
    INCLUDE([CategoryCode]);


GO

