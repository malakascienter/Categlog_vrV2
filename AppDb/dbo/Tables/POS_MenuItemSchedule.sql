CREATE TABLE [dbo].[POS_MenuItemSchedule] (
    [ID]         BIGINT       IDENTITY (1, 1) NOT NULL,
    [MenuCode]   VARCHAR (10) CONSTRAINT [DF_POS_MenuItemSchedule_MenuCode] DEFAULT ('') NOT NULL,
    [FromDate]   DATE         CONSTRAINT [DF_POS_MenuItemSchedule_FromDate] DEFAULT (getdate()) NOT NULL,
    [ToDate]     DATE         CONSTRAINT [DF_Table_1_FromDate1] DEFAULT (getdate()) NOT NULL,
    [FromTime]   DATETIME     CONSTRAINT [DF_Table_1_FromDate1_1] DEFAULT (getdate()) NOT NULL,
    [ToTime]     DATETIME     CONSTRAINT [DF_Table_1_ToDate1] DEFAULT (getdate()) NOT NULL,
    [IsUpload]   BIT          DEFAULT ((0)) NOT NULL,
    [PropertyId] INT          DEFAULT ((0)) NOT NULL
);


GO

