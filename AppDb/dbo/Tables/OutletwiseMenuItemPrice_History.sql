CREATE TABLE [dbo].[OutletwiseMenuItemPrice_History] (
    [Id]                   INT         NOT NULL,
    [MainMenuCode]         VARCHAR (4) NOT NULL,
    [Outlet]               VARCHAR (3) NOT NULL,
    [DineInPrice]          MONEY       NOT NULL,
    [TakeOutPrice]         MONEY       NOT NULL,
    [DeliveryPrice]        MONEY       NOT NULL,
    [EffectiveDate]        DATETIME    NOT NULL,
    [CreatedUserId]        INT         NULL,
    [CreatedDateTime]      DATETIME    NULL,
    [LastModifiedUserId]   INT         NULL,
    [LastModifiedDateTime] DATETIME    CONSTRAINT [DF_OutletwiseMenuItemPrice_History_LastModifiedDateTime] DEFAULT (getdate()) NULL,
    [IsUpload]             BIT         NULL,
    [SysDate]              DATETIME    CONSTRAINT [DF_OutletwiseMenuItemPrice_SysDate] DEFAULT (getdate()) NOT NULL
);


GO

