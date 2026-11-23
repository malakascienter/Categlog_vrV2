CREATE TABLE [dbo].[Waiter_History] (
    [Id]              INT          NOT NULL,
    [Code]            VARCHAR (10) NOT NULL,
    [Name]            VARCHAR (20) NOT NULL,
    [CardNo]          VARCHAR (50) NOT NULL,
    [Active]          BIT          CONSTRAINT [DF_Waiter_History_Active] DEFAULT ((1)) NOT NULL,
    [PropertyId]      INT          NOT NULL,
    [CreatedUserId]   INT          NULL,
    [CreatedDateTime] DATETIME     NULL,
    [UpatedUserId]    INT          NULL,
    [UpdatedDateTime] DATETIME     NULL,
    [SysDate]         DATETIME     CONSTRAINT [DF_Waiter_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsUpload]        BIT          NULL,
    [IsViewAllOrders] BIT          CONSTRAINT [DF_Waiter_History_IsViewAllOrders] DEFAULT ((0)) NOT NULL,
    [IsCashier]       BIT          CONSTRAINT [DF_Waiter_History_IsCashier] DEFAULT ((0)) NOT NULL,
    [IsDeleted]       BIT          DEFAULT ((0)) NOT NULL
);


GO

