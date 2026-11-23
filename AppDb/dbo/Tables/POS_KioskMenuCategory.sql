CREATE TABLE [dbo].[POS_KioskMenuCategory] (
    [CategoryID]         INT          IDENTITY (1, 1) NOT NULL,
    [CategoryName]       VARCHAR (50) CONSTRAINT [DF__POS_Kiosk__Categ__2FF3DA25] DEFAULT ('') NOT NULL,
    [SortOrder]          INT          CONSTRAINT [DF__POS_Kiosk__SortO__30E7FE5E] DEFAULT ((0)) NOT NULL,
    [IsActive]           BIT          CONSTRAINT [DF__POS_Kiosk__IsAct__31DC2297] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]      INT          CONSTRAINT [DF__POS_Kiosk__Creat__32D046D0] DEFAULT ((0)) NOT NULL,
    [CreatedDateTime]    DATETIME     CONSTRAINT [DF__POS_Kiosk__Creat__33C46B09] DEFAULT (getdate()) NOT NULL,
    [LastEditedUserId]   INT          CONSTRAINT [DF__POS_Kiosk__LastE__34B88F42] DEFAULT ((0)) NOT NULL,
    [LastEditedDateTime] DATETIME     CONSTRAINT [DF__POS_Kiosk__LastE__35ACB37B] DEFAULT (getdate()) NOT NULL,
    [ItemType]           CHAR (1)     CONSTRAINT [DF__POS_Kiosk__ItemT__36A0D7B4] DEFAULT ('O') NOT NULL,
    [PropertyId]         INT          CONSTRAINT [DF__POS_Kiosk__Prope__397D445F] DEFAULT ((0)) NOT NULL
);


GO

