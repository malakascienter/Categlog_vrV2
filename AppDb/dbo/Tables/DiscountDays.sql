CREATE TABLE [dbo].[DiscountDays] (
    [Code]       VARCHAR (2)  CONSTRAINT [DF_DiscountDays_Code] DEFAULT ('') NOT NULL,
    [DayName]    VARCHAR (50) CONSTRAINT [DF_DiscountDays_DayName] DEFAULT ('') NOT NULL,
    [SysDate]    DATETIME     CONSTRAINT [DF_DiscountDays_SysDate] DEFAULT (getdate()) NOT NULL,
    [PropertyId] INT          NOT NULL
);


GO

