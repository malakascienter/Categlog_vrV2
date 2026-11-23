CREATE TABLE [dbo].[POS_SetMenuSubLevelDetails] (
    [SubLevelDetailID]  INT          IDENTITY (1, 1) NOT NULL,
    [SetMenuItemID]     VARCHAR (10) CONSTRAINT [DF__POS_SetMe__SetMe__68924BB6] DEFAULT ('0') NOT NULL,
    [SetMenuLevelID]    VARCHAR (10) CONSTRAINT [DF__POS_SetMe__SetMe__69866FEF] DEFAULT ('0') NOT NULL,
    [SetMenuSubLevelID] VARCHAR (10) CONSTRAINT [DF__POS_SetMe__SetMe__6A7A9428] DEFAULT ('0') NOT NULL,
    [SortOrder]         SMALLINT     CONSTRAINT [DF__POS_SetMe__SortO__6B6EB861] DEFAULT ((0)) NOT NULL,
    [SubLevelQuantity]  TINYINT      CONSTRAINT [DF__POS_SetMe__SubLe__6C62DC9A] DEFAULT ((0)) NOT NULL,
    [IsActive]          BIT          CONSTRAINT [DF__POS_SetMe__IsAct__6D5700D3] DEFAULT ((0)) NOT NULL,
    [PropertyId]        INT          DEFAULT ((0)) NOT NULL,
    [WebUpload]         BIT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_SetMenuSubLevelDetails] PRIMARY KEY CLUSTERED ([SubLevelDetailID] ASC)
);


GO

