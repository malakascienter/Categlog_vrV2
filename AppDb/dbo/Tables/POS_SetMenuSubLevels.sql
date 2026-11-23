CREATE TABLE [dbo].[POS_SetMenuSubLevels] (
    [SetMenuSubLevelID] VARCHAR (10) NOT NULL,
    [Description]       VARCHAR (30) NOT NULL,
    [IsActive]          BIT          DEFAULT ((0)) NOT NULL,
    [ButtonColour]      VARCHAR (9)  CONSTRAINT [DF_POS_SetMenuSubLevels_ButtonColour] DEFAULT ('') NOT NULL,
    [PropertyId]        INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_SetMenuSubLevels] PRIMARY KEY CLUSTERED ([SetMenuSubLevelID] ASC)
);


GO

