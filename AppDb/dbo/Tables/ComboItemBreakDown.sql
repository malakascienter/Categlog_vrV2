CREATE TABLE [dbo].[ComboItemBreakDown] (
    [Id]           INT      IDENTITY (1, 1) NOT NULL,
    [mainmenucode] CHAR (4) NULL,
    [subItemcode]  CHAR (4) NULL,
    [PropertyId]   INT      CONSTRAINT [DF_ComboItemBreakDown_PropertyId] DEFAULT ((1)) NOT NULL
);


GO

