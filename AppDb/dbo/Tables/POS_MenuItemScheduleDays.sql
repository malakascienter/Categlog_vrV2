CREATE TABLE [dbo].[POS_MenuItemScheduleDays] (
    [ID]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [MenuCode]   VARCHAR (10) CONSTRAINT [DF_POS_MenuItemScheduleDays_MenuCode] DEFAULT ('') NOT NULL,
    [DayName]    VARCHAR (50) CONSTRAINT [DF_POS_MenuItemScheduleDays_DayName] DEFAULT ('') NOT NULL,
    [PropertyId] INT          DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_POS_MenuItemScheduleDays] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

