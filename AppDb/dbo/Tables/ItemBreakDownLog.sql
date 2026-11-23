CREATE TABLE [dbo].[ItemBreakDownLog] (
    [Id]             INT             IDENTITY (1, 1) NOT NULL,
    [MainMenuCode]   CHAR (4)        NULL,
    [SubMenuCode]    CHAR (4)        NULL,
    [SubMenuCode2]   CHAR (4)        DEFAULT (' ') NULL,
    [SubMenuCode3]   CHAR (4)        NULL,
    [SubMenuCode4]   CHAR (4)        NULL,
    [RecipeCode]     CHAR (6)        NULL,
    [Qty]            MONEY           DEFAULT ((0)) NOT NULL,
    [PropertyId]     INT             NULL,
    [IsUpload]       BIT             NULL,
    [SysDate]        DATETIME        DEFAULT (getdate()) NOT NULL,
    [AdditionalCost] DECIMAL (18, 2) DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_ItemBreakDownLog] PRIMARY KEY NONCLUSTERED ([Id] ASC)
);


GO

