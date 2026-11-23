CREATE TABLE [dbo].[Waiter] (
    [Id]              INT          IDENTITY (1, 1) NOT NULL,
    [Code]            VARCHAR (10) NOT NULL,
    [Name]            VARCHAR (20) NOT NULL,
    [CardNo]          VARCHAR (50) NOT NULL,
    [Active]          BIT          CONSTRAINT [DF_Waiter_Active] DEFAULT ((1)) NOT NULL,
    [PropertyId]      INT          NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpatedUserId]    INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [IsUpload]        BIT          CONSTRAINT [DF_Waiter_IsUpload] DEFAULT ((0)) NOT NULL,
    [IsViewAllOrders] BIT          CONSTRAINT [DF_Waiter_IsViewAllOrders] DEFAULT ((0)) NOT NULL,
    [IsCashier]       BIT          CONSTRAINT [DF_Waiter_IsCashier] DEFAULT ((0)) NOT NULL,
    [IsDeleted]       BIT          DEFAULT ((0)) NOT NULL
);


GO

