CREATE TABLE [dbo].[BasisMealTemp] (
    [Id]                 INT           IDENTITY (1, 1) NOT NULL,
    [Pax]                INT           NULL,
    [HotelReservationNo] VARCHAR (20)  NULL,
    [RoomID]             INT           NULL,
    [RoomName]           VARCHAR (50)  NULL,
    [GuestProfileID]     INT           NULL,
    [GuestProfileName]   VARCHAR (500) NULL,
    [MealPlanID]         INT           NULL,
    [MealPlanName]       VARCHAR (200) NULL,
    [PropertyId]         INT           NULL,
    [MealCode]           CHAR (1)      NULL,
    [LogDate]            DATETIME      CONSTRAINT [DF_BasisMealTemp_LogDate] DEFAULT (getdate()) NOT NULL,
    [HeadCount]          INT           NULL,
    [BreakfastAllowed]   INT           NULL,
    [LunchAllowed]       INT           NULL,
    [DinnerAllowed]      INT           NULL
);


GO

