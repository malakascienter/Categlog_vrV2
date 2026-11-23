CREATE TABLE [dbo].[POS_SetMenuItemDetails] (
    [LevelItemID]       INT             IDENTITY (1, 1) NOT NULL,
    [SetMenuItemID]     VARCHAR (4)     CONSTRAINT [DF_POS_SetMenuItemDetails_SetMenuItemID] DEFAULT ('') NOT NULL,
    [SetMenuLevelID]    VARCHAR (4)     CONSTRAINT [DF_POS_SetMenuItemDetails_SetMenuLevelID] DEFAULT ((0)) NOT NULL,
    [MenuItemID]        VARCHAR (4)     CONSTRAINT [DF_POS_SetMenuItemDetails_MenuItemID] DEFAULT ('') NOT NULL,
    [SortOrder]         SMALLINT        CONSTRAINT [DF_POS_SetMenuItemDetails_SortOrder] DEFAULT ((0)) NOT NULL,
    [SetMenuSubLevelID] VARCHAR (4)     DEFAULT ('') NOT NULL,
    [AddRate]           NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [IsActive]          BIT             DEFAULT ((0)) NOT NULL,
    [IsHalfAllow]       BIT             DEFAULT ((0)) NOT NULL,
    [PropertyId]        INT             DEFAULT ((0)) NOT NULL,
    [WebUpload]         BIT             DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_SetMenuItemDetails] PRIMARY KEY CLUSTERED ([LevelItemID] ASC)
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Main Item Menu ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_SetMenuItemDetails', @level2type = N'COLUMN', @level2name = N'MenuItemID';


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Main Item Menu ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_SetMenuItemDetails', @level2type = N'COLUMN', @level2name = N'SetMenuItemID';


GO

