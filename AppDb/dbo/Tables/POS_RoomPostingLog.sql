CREATE TABLE [dbo].[POS_RoomPostingLog] (
    [UserId]           VARCHAR (20)  CONSTRAINT [DF_Table_2_UserId1_1] DEFAULT ('') NOT NULL,
    [WaiterCode]       VARCHAR (20)  CONSTRAINT [DF_POS_RoomLog_WaiterCode] DEFAULT ('') NOT NULL,
    [POSNo]            VARCHAR (5)   CONSTRAINT [DF_POS_RoomLog_POSNo] DEFAULT ('') NOT NULL,
    [ComputerName]     VARCHAR (100) CONSTRAINT [DF_POS_RoomLog_ComputerName] DEFAULT ('') NOT NULL,
    [OrderNo]          VARCHAR (10)  CONSTRAINT [DF_POS_RoomLog_OrderNo] DEFAULT ('') NOT NULL,
    [OrderDate]        DATETIME      CONSTRAINT [DF_POS_RoomLog_OrderDate] DEFAULT (getdate()) NOT NULL,
    [Outlet]           VARCHAR (3)   CONSTRAINT [DF_POS_RoomLog_Outlet] DEFAULT ('L1') NOT NULL,
    [PropertyId]       INT           CONSTRAINT [DF_POS_RoomLog_PropertyId] DEFAULT ((0)) NOT NULL,
    [PostingUserId]    INT           CONSTRAINT [DF_Table_2_UserId] DEFAULT ((0)) NOT NULL,
    [JsonText]         TEXT          CONSTRAINT [DF_POS_RoomLog_JsonText] DEFAULT ('') NOT NULL,
    [RoomPostingDocNo] VARCHAR (10)  CONSTRAINT [DF_POS_RoomPostingLog_RoomPostingDocNo] DEFAULT ('') NOT NULL,
    [sysDate]          DATETIME      CONSTRAINT [DF_POS_RoomLog_sysDate] DEFAULT (getdate()) NOT NULL
);


GO

