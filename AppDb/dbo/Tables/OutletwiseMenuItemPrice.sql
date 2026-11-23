CREATE TABLE [dbo].[OutletwiseMenuItemPrice] (
    [Id]                   INT         IDENTITY (1, 1) NOT NULL,
    [MainMenuCode]         VARCHAR (4) NOT NULL,
    [Outlet]               VARCHAR (3) NOT NULL,
    [DineInPrice]          MONEY       NOT NULL,
    [TakeOutPrice]         MONEY       NOT NULL,
    [DeliveryPrice]        MONEY       NOT NULL,
    [EffectiveDate]        DATETIME    NOT NULL,
    [CreatedUserId]        INT         NULL,
    [CreatedDateTime]      DATETIME    NULL,
    [LastModifiedUserId]   INT         NULL,
    [LastModifiedDateTime] DATETIME    CONSTRAINT [DF_OutletwiseMenuItemPrice_LastModifiedDateTime] DEFAULT (getdate()) NULL,
    [IsUpload]             BIT         NULL,
    CONSTRAINT [PK_OutletwiseMenuItemPrice] PRIMARY KEY CLUSTERED ([MainMenuCode] ASC, [Outlet] ASC)
);


GO

