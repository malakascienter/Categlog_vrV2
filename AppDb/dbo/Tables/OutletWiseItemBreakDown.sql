CREATE TABLE [dbo].[OutletWiseItemBreakDown] (
    [MainMenuCode] VARCHAR (10) NOT NULL,
    [SubMenuCode]  VARCHAR (10) DEFAULT ('') NOT NULL,
    [RecipeCode]   CHAR (6)     NOT NULL,
    [Qty]          MONEY        NOT NULL,
    [SubMenuCode2] VARCHAR (10) DEFAULT ('') NULL,
    [SubMenuCode3] VARCHAR (10) DEFAULT ('') NULL,
    [SubMenuCode4] VARCHAR (10) DEFAULT ('') NULL,
    [Outlet]       VARCHAR (5)  NULL,
    [PropertyId]   INT          DEFAULT ((0)) NOT NULL
);


GO

