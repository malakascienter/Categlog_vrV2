CREATE TABLE [dbo].[ItemBreakDown] (
    [MainMenuCode]   CHAR (4)        NULL,
    [SubMenuCode]    CHAR (4)        NULL,
    [SubMenuCode2]   CHAR (4)        CONSTRAINT [DF_ItemBreakDown_SubmenuCode2] DEFAULT (' ') NULL,
    [SubMenuCode3]   CHAR (4)        NULL,
    [SubMenuCode4]   CHAR (4)        NULL,
    [RecipeCode]     CHAR (6)        NULL,
    [Qty]            MONEY           CONSTRAINT [DF_ItemBreakDown_Qty] DEFAULT ((0)) NOT NULL,
    [PropertyId]     INT             NULL,
    [IsUpload]       BIT             NULL,
    [SysDate]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [AdditionalCost] DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    [Id]             BIGINT          IDENTITY (1, 1) NOT NULL
);


GO

CREATE NONCLUSTERED INDEX [IDX_ItemBreakDown_RecipeCode_PropertyId]
    ON [dbo].[ItemBreakDown]([RecipeCode] ASC, [PropertyId] ASC)
    INCLUDE([MainMenuCode]);


GO

