CREATE TYPE [dbo].[POS_SetMenuItemDetails_UDT] AS TABLE (
    [LevelItemID]       INT              NOT NULL,
    [SetMenuItemID]     VARCHAR (10)     NULL,
    [SetMenuLevelID]    VARCHAR (10)     NOT NULL,
    [MenuItemID]        VARCHAR (10)     NULL,
    [SortOrder]         SMALLINT         NOT NULL,
    [AddRate]           DECIMAL (18, 10) NULL,
    [SetMenuSubLevelId] VARCHAR (10)     NOT NULL,
    [IsActive]          BIT              NOT NULL);


GO

