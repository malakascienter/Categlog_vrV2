CREATE TABLE [dbo].[POS_DayEndAuthorizationLog] (
    [Id]                 BIGINT        IDENTITY (1, 1) NOT NULL,
    [LogDateTime]        DATETIME      CONSTRAINT [DF_DayEndAuthLog_LogDateTime] DEFAULT (getdate()) NOT NULL,
    [PropertyId]         INT           NULL,
    [HotelDate]          DATE          NULL,
    [Outlet]             VARCHAR (10)  NULL,
    [CurrentUserId]      INT           NULL,
    [CurrentUserName]    VARCHAR (100) NULL,
    [AuthorizedUserName] VARCHAR (100) NULL,
    [IsSuccess]          BIT           NULL,
    [ResultDescription]  VARCHAR (500) NULL,
    [Reason]             VARCHAR (200) NULL,
    [IpAddress]          VARCHAR (50)  NULL,
    [MachineName]        VARCHAR (300) NULL,
    CONSTRAINT [PK_POS_DayEndAuthorizationLog] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_DayEndAuthLog_Property_Date]
    ON [dbo].[POS_DayEndAuthorizationLog]([PropertyId] ASC, [HotelDate] ASC, [LogDateTime] ASC);


GO

