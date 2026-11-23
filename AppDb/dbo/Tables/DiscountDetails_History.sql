CREATE TABLE [dbo].[DiscountDetails_History] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Code]               CHAR (2)        NOT NULL,
    [OrderType]          VARCHAR (1)     NOT NULL,
    [MenuItemID]         VARCHAR (10)    NOT NULL,
    [DiscountPercentage] NUMERIC (18, 2) NOT NULL,
    [DiscountValue]      NUMERIC (18, 2) NOT NULL,
    [BuyQuantity]        NUMERIC (18, 2) NOT NULL,
    [DiscountQuantity]   NUMERIC (18, 2) NOT NULL,
    [IsUpload]           BIT             NULL,
    [PropertyId]         INT             NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [UpdatedUserId]      INT             NULL,
    [UpdatedDateTime]    DATETIME        NULL
);


GO

