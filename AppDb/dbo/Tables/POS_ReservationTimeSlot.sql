CREATE TABLE [dbo].[POS_ReservationTimeSlot] (
    [TimeSlotID]  INT           IDENTITY (1, 1) NOT NULL,
    [Description] VARCHAR (100) CONSTRAINT [DF_POS_ReservationTimeSlot_Description] DEFAULT ('') NOT NULL,
    [FromTime]    DATETIME      CONSTRAINT [DF_POS_ReservationTimeSlot_FromTime] DEFAULT (getdate()) NOT NULL,
    [ToTime]      DATETIME      CONSTRAINT [DF_Table_1_FromTime1_1] DEFAULT (getdate()) NOT NULL,
    [MaxPaxLimit] INT           DEFAULT ((230)) NOT NULL
);


GO

