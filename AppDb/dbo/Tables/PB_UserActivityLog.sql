CREATE TABLE [dbo].[PB_UserActivityLog] (
    [ID]             BIGINT        IDENTITY (1, 1) NOT NULL,
    [UserId]         VARCHAR (20)  CONSTRAINT [DF__PB_UserA__UserI__5927CC86] DEFAULT ('') NOT NULL,
    [WaiterCode]     VARCHAR (20)  CONSTRAINT [DF_PB_UserActivityLog_WaiterCode] DEFAULT ('') NOT NULL,
    [Outlet]         VARCHAR (3)   CONSTRAINT [DF__PB_UserA__Outle__5A1BF0BF] DEFAULT ('L1') NOT NULL,
    [OrderNo]        VARCHAR (10)  CONSTRAINT [DF__PB_UserA__Order__5B1014F8] DEFAULT ('') NOT NULL,
    [TempOrderNo]    VARCHAR (10)  CONSTRAINT [DF__PB_UserA__TempO__5C043931] DEFAULT ('') NOT NULL,
    [OrderDate]      DATETIME      CONSTRAINT [DF__PB_UserA__Order__5CF85D6A] DEFAULT (getdate()) NOT NULL,
    [POSNo]          VARCHAR (5)   CONSTRAINT [DF__PB_UserA__POSNo__5DEC81A3] DEFAULT ('') NOT NULL,
    [ComputerName]   VARCHAR (15)  NOT NULL,
    [AccessCode]     VARCHAR (100) NOT NULL,
    [Remark]         VARCHAR (250) CONSTRAINT [DF__PB_UserA__Remar__5EE0A5DC] DEFAULT ('') NOT NULL,
    [SysDate]        DATETIME      CONSTRAINT [DF__PB_UserA__SysDa__5FD4CA15] DEFAULT (getdate()) NOT NULL,
    [ProductVersion] VARCHAR (50)  CONSTRAINT [DF_PB_UserActivityLog_ProductVersion] DEFAULT ('') NOT NULL,
    [PropertyId]     INT           DEFAULT ((0)) NOT NULL
);


GO

