CREATE TABLE [dbo].[Sync_Log] (
    [ID]          BIGINT        NOT NULL,
    [PropertyId]  INT           CONSTRAINT [DF_Sync_Log_PropertyId] DEFAULT ((0)) NOT NULL,
    [Description] VARCHAR (MAX) CONSTRAINT [DF_Sync_Log_Description] DEFAULT ('') NOT NULL,
    [SysDate]     DATETIME      CONSTRAINT [DF_Sync_Log_SysDate] DEFAULT (getdate()) NOT NULL,
    [IsError]     BIT           CONSTRAINT [DF_Sync_Log_IsError] DEFAULT ((0)) NOT NULL,
    [Outlet]      VARCHAR (5)   CONSTRAINT [DF_Sync_Log_Outlet] DEFAULT ('') NOT NULL
);


GO

