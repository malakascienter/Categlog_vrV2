CREATE TABLE [dbo].[DiscountDetails] (
    [Id]                 INT             IDENTITY (1, 1) NOT NULL,
    [Code]               CHAR (2)        NOT NULL,
    [OrderType]          VARCHAR (1)     CONSTRAINT [DF__DiscountD__Order__5F238C03] DEFAULT ('') NOT NULL,
    [MenuItemID]         VARCHAR (10)    NOT NULL,
    [DiscountPercentage] NUMERIC (18, 2) CONSTRAINT [DF__DiscountD__Disco__6017B03C] DEFAULT ((0)) NOT NULL,
    [DiscountValue]      NUMERIC (18, 2) CONSTRAINT [DF__DiscountD__Disco__610BD475] DEFAULT ((0)) NOT NULL,
    [BuyQuantity]        NUMERIC (18, 2) CONSTRAINT [DF__DiscountD__BuyQu__61FFF8AE] DEFAULT ((0)) NOT NULL,
    [DiscountQuantity]   NUMERIC (18, 2) CONSTRAINT [DF__DiscountD__Disco__62F41CE7] DEFAULT ((0)) NOT NULL,
    [IsUpload]           BIT             NULL,
    [PropertyId]         INT             NULL,
    [CreatedUserId]      INT             NULL,
    [CreatedDateTime]    DATETIME        NULL,
    [UpdatedUserId]      INT             NULL,
    [UpdatedDateTime]    DATETIME        NULL,
    [IsBuyItem]          BIT             CONSTRAINT [DF_DiscountDetails_IsBuyItem] DEFAULT ((0)) NOT NULL,
    [IsDiscountItem]     BIT             CONSTRAINT [DF_DiscountDetails_IsDiscountItem] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DiscountDetails] PRIMARY KEY CLUSTERED ([Id] ASC, [Code] ASC)
);


GO

