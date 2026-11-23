CREATE TABLE [dbo].[MenuItemWiseAlternatives] (
    [MainMenuCode]      VARCHAR (6)     CONSTRAINT [DF_MenuItemWiseAlternatives_MainMenuCode] DEFAULT ('') NOT NULL,
    [MenuCode]          VARCHAR (6)     CONSTRAINT [DF_MenuItemWiseAlternatives_MainMenuCode1] DEFAULT ('') NOT NULL,
    [AlternateMenuCode] VARCHAR (6)     CONSTRAINT [DF_MenuItemWiseAlternatives_AlternateMainMenuCode] DEFAULT ('') NOT NULL,
    [SeqNo]             INT             CONSTRAINT [DF_MenuItemWiseAlternatives_SeqNo] DEFAULT ((0)) NOT NULL,
    [AddRate]           NUMERIC (18, 4) CONSTRAINT [DF_MenuItemWiseAlternatives_AddRate] DEFAULT ((0)) NOT NULL,
    [ActionButtonID]    INT             CONSTRAINT [DF_MenuItemWiseAlternatives_ActionButtonID] DEFAULT ((0)) NOT NULL,
    [Qty]               INT             CONSTRAINT [DF_MenuItemWiseAlternatives_Qty_1] DEFAULT ((1)) NOT NULL,
    [IsUpload]          BIT             CONSTRAINT [DF_MenuItemWiseAlternatives_IsUpload_1] DEFAULT ((0)) NOT NULL,
    [Id]                INT             IDENTITY (1, 1) NOT NULL
);


GO

