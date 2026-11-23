CREATE TABLE [dbo].[LocationWiseDiscount] (
    [Id]              BIGINT       IDENTITY (1, 1) NOT NULL,
    [DiscountId]      INT          CONSTRAINT [DF_LocationWiseDiscount_DiscountId] DEFAULT ((0)) NOT NULL,
    [DiscountCode]    VARCHAR (10) NOT NULL,
    [LocationId]      INT          NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpdateUserId]    INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [PropertyId]      INT          NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_LocationWiseDiscount_IsUpload] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_LocationWiseDiscount] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

