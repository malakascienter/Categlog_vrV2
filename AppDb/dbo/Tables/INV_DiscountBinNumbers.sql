CREATE TABLE [dbo].[INV_DiscountBinNumbers] (
    [Id]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [DiscountId]      INT          NOT NULL,
    [DiscountCode]    VARCHAR (10) NOT NULL,
    [BinNumber]       VARCHAR (10) NOT NULL,
    [PropertyId]      INT          NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     CONSTRAINT [DF_INV_DiscountBinNumbers_Created] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_INV_DiscountBinNumbers] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_INV_DiscountBinNumbers_Discount]
    ON [dbo].[INV_DiscountBinNumbers]([DiscountId] ASC, [PropertyId] ASC)
    INCLUDE([BinNumber]);


GO

