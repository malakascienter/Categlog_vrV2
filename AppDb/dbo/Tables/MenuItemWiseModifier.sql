CREATE TABLE [dbo].[MenuItemWiseModifier] (
    [ID]               INT             IDENTITY (1, 1) NOT NULL,
    [MainMenuCode]     VARCHAR (6)     CONSTRAINT [DF_MenuItemWiseModifier_MainMenuCode] DEFAULT ('') NOT NULL,
    [ModifierMenuCode] VARCHAR (6)     CONSTRAINT [DF_Table_1_MainMenuCode1] DEFAULT ('') NOT NULL,
    [SeqNo]            INT             CONSTRAINT [DF_MenuItemWiseModifier_SeqNo] DEFAULT ((0)) NOT NULL,
    [ActionID]         INT             CONSTRAINT [DF_MenuItemWiseModifier_ActionID] DEFAULT ((0)) NOT NULL,
    [PropertyId]       INT             NULL,
    [IsUpload]         BIT             NULL,
    [CreatedUserId]    NCHAR (10)      NULL,
    [CreatedDateTime]  DATETIME        NULL,
    [UpdatedUserId]    INT             NULL,
    [UpdatedDateTime]  DATETIME        NULL,
    [MaxQty]           NUMERIC (18, 2) NULL
);


GO

