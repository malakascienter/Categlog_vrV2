CREATE TABLE [dbo].[INV_EODNotificationDetails] (
    [Id]           BIGINT        IDENTITY (1, 1) NOT NULL,
    [Outlet]       VARCHAR (5)   CONSTRAINT [DF_INV_EODNotificationDetails_Outlet] DEFAULT ('') NOT NULL,
    [EODDate]      DATE          CONSTRAINT [DF_INV_EODNotificationDetails_EODDate] DEFAULT (getdate()) NOT NULL,
    [PropertyId]   INT           CONSTRAINT [DF_INV_EODNotificationDetails_PropertyId] DEFAULT ((0)) NOT NULL,
    [UserId]       VARCHAR (50)  CONSTRAINT [DF_INV_EODNotificationDetails_UserId] DEFAULT ('') NOT NULL,
    [EmailSubject] VARCHAR (500) CONSTRAINT [DF_INV_EODNotificationDetails_EmailSubject] DEFAULT ('') NOT NULL,
    [IsMailSend]   BIT           CONSTRAINT [DF_INV_EODNotificationDetails_IsMailSend] DEFAULT ((0)) NOT NULL,
    [SysDate]      DATETIME      CONSTRAINT [DF_INV_EODNotificationDetails_SysDate] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_INV_EODNotificationDetails] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

