CREATE TABLE [dbo].[MenuItemWiseAlternatives_History] (
    [Id]                INT             NOT NULL,
    [SysDate]           DATETIME        CONSTRAINT [DF_MenuItemWiseAlternatives_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [MainMenuCode]      VARCHAR (6)     NOT NULL,
    [MenuCode]          VARCHAR (6)     NOT NULL,
    [AlternateMenuCode] VARCHAR (6)     NOT NULL,
    [SeqNo]             INT             NOT NULL,
    [AddRate]           NUMERIC (18, 4) NOT NULL,
    [Qty]               INT             CONSTRAINT [DF_MenuItemWiseAlternatives_History_Qty] DEFAULT ((1)) NOT NULL,
    [ActionButtonID]    INT             NOT NULL,
    [IsUpload]          BIT             NOT NULL
);


GO

