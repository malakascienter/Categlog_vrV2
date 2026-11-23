CREATE TABLE [dbo].[DiscountWiseTier] (
    [Id]           BIGINT       IDENTITY (1, 1) NOT NULL,
    [DiscountCode] VARCHAR (10) NOT NULL,
    [TierId]       INT          NOT NULL,
    [PropertyId]   INT          NULL,
    CONSTRAINT [PK_DiscountWiseTier] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_DiscountWiseTier_DiscountCode]
    ON [dbo].[DiscountWiseTier]([DiscountCode] ASC, [PropertyId] ASC)
    INCLUDE([TierId]);


GO

