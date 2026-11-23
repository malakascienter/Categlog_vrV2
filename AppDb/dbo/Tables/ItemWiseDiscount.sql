CREATE TABLE [dbo].[ItemWiseDiscount] (
    [Id]                 INT          IDENTITY (1, 1) NOT NULL,
    [DiscountId]         INT          NULL,
    [ItemCode]           VARCHAR (10) NULL,
    [Discountcode]       VARCHAR (10) NULL,
    [FromTime]           DATETIME     NULL,
    [ToTime]             DATETIME     NULL,
    [CreatedUserId]      INT          NULL,
    [CreatedDateTime]    DATETIME     NULL,
    [LastEditedUserId]   INT          NULL,
    [LastEditedDateTime] DATETIME     NULL,
    CONSTRAINT [PK_ItemWiseDiscount] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

