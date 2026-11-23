CREATE TABLE [dbo].[POS_SetMenuLevelDetails] (
    [LevelDetailID]     INT           IDENTITY (1, 1) NOT NULL,
    [SetMenuItemID]     VARCHAR (4)   CONSTRAINT [DF_POS_SetMenuLevelDetails_SetMenuItemID] DEFAULT ('') NOT NULL,
    [SetMenuLevelID]    VARCHAR (4)   CONSTRAINT [DF_POS_SetMenuLevelDetails_SetMenuLevelID] DEFAULT ('') NOT NULL,
    [SortOrder]         SMALLINT      CONSTRAINT [DF_POS_SetMenuLevelDetails_SortOrder] DEFAULT ((0)) NOT NULL,
    [LevelQuantity]     TINYINT       CONSTRAINT [DF_POS_SetMenuLevelDetails_LevelQuantity] DEFAULT ((0)) NOT NULL,
    [SetMenuSubLevelID] VARCHAR (4)   DEFAULT ('') NOT NULL,
    [MaxQuantity]       TINYINT       CONSTRAINT [DF_POS_SetMenuLevelDetails_MaxQuantity_1] DEFAULT ((0)) NOT NULL,
    [IsOptional]        BIT           DEFAULT ((0)) NOT NULL,
    [IsDependLevel]     BIT           DEFAULT ((0)) NOT NULL,
    [IsActive]          BIT           DEFAULT ((0)) NOT NULL,
    [DependLevelId]     NVARCHAR (10) DEFAULT ('0') NOT NULL,
    [PropertyId]        INT           DEFAULT ((0)) NOT NULL,
    [Id]                AS            ([LevelDetailID]),
    [WebUpload]         BIT           DEFAULT ((0)) NOT NULL,
    [ItemCount]         INT           NULL,
    CONSTRAINT [PK_POS_SetMenuLevelDetails] PRIMARY KEY CLUSTERED ([LevelDetailID] ASC)
);


GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Main Item Menu ID', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'POS_SetMenuLevelDetails', @level2type = N'COLUMN', @level2name = N'SetMenuItemID';


GO

