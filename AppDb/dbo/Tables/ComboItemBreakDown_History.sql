CREATE TABLE [dbo].[ComboItemBreakDown_History] (
    [Id]           INT      NOT NULL,
    [SysDate]      DATETIME CONSTRAINT [DF_ComboItemBreakDown_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [mainmenucode] CHAR (4) NULL,
    [subItemcode]  CHAR (4) NULL,
    [PropertyId]   INT      NULL
);


GO

