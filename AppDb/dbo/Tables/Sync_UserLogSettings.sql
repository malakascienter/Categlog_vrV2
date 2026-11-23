CREATE TABLE [dbo].[Sync_UserLogSettings] (
    [PropertyId]  INT           CONSTRAINT [DF_Sync_UserLogSettings_PropertyId] DEFAULT ((0)) NOT NULL,
    [AccessCode]  VARCHAR (100) CONSTRAINT [DF_Sync_UserLogSettings_AccessCode] DEFAULT ('') NOT NULL,
    [Description] VARCHAR (100) DEFAULT ('') NOT NULL,
    [SortOrder]   TINYINT       CONSTRAINT [DF_Sync_UserLogSettings_SortOrder] DEFAULT ((0)) NOT NULL,
    [IsActive]    BIT           CONSTRAINT [DF_Sync_UserLogSettings_IsActive] DEFAULT ((0)) NOT NULL,
    [IsSplit]     BIT           DEFAULT ((0)) NOT NULL,
    [IsCombine]   BIT           DEFAULT ((0)) NOT NULL
);


GO

