CREATE TYPE [dbo].[POS_SetMenuDependItemDetails_UDT] AS TABLE (
    [DependItemDetailsID] INT              NOT NULL,
    [MainItemCode]        VARCHAR (10)     NOT NULL,
    [LevelCode]           VARCHAR (10)     NOT NULL,
    [LevelItemId]         VARCHAR (10)     NOT NULL,
    [DepenItemId]         VARCHAR (10)     NOT NULL,
    [Price]               DECIMAL (18, 10) NOT NULL,
    [IsActive]            BIT              NOT NULL,
    [CreatedUser]         NVARCHAR (50)    NULL,
    [ModifiedUser]        NVARCHAR (50)    NULL);


GO

