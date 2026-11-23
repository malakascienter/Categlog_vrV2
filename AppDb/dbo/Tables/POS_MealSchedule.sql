CREATE TABLE [dbo].[POS_MealSchedule] (
    [MealID]   TINYINT      IDENTITY (1, 1) NOT NULL,
    [MealCode] VARCHAR (1)  CONSTRAINT [DF_POS_MealSchedule_MealCode] DEFAULT ('') NOT NULL,
    [Meal]     VARCHAR (50) CONSTRAINT [DF_Table_1_MealCode1] DEFAULT ('') NOT NULL,
    [FromTime] TIME (7)     CONSTRAINT [DF_POS_MealSchedule_FromTime] DEFAULT (getdate()) NOT NULL,
    [ToTime]   TIME (7)     CONSTRAINT [DF_Table_1_FromTime1_2] DEFAULT (getdate()) NOT NULL
);


GO

