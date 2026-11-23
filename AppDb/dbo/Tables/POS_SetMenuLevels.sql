CREATE TABLE [dbo].[POS_SetMenuLevels] (
    [SetMenuLevelID]   VARCHAR (4)  CONSTRAINT [DF_POS_SetMenuLevels_SetMenuLevelID] DEFAULT ('') NOT NULL,
    [Description]      VARCHAR (30) CONSTRAINT [DF_POS_SetMenuLevels_Description] DEFAULT ('') NOT NULL,
    [CreatedUserId]    INT          NULL,
    [CreatedDateTime]  DATETIME     NULL,
    [ModifiedUserId]   INT          NULL,
    [ModifiedDateTime] DATETIME     NULL,
    [IsActive]         BIT          DEFAULT ((0)) NOT NULL,
    [PropertyId]       INT          DEFAULT ((0)) NOT NULL,
    [Id]               BIGINT       IDENTITY (1, 1) NOT NULL,
    CONSTRAINT [PK_POS_SetMenuLevels] PRIMARY KEY CLUSTERED ([SetMenuLevelID] ASC)
);


GO

