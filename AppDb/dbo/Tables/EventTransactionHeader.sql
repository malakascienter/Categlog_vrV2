CREATE TABLE [dbo].[EventTransactionHeader] (
    [ID]                 INT            IDENTITY (1, 1) NOT NULL,
    [EventId]            INT            NOT NULL,
    [MobileNo]           VARCHAR (20)   NOT NULL,
    [Salutation]         NVARCHAR (10)  NOT NULL,
    [FirstName]          NVARCHAR (100) NOT NULL,
    [LastName]           NVARCHAR (100) NOT NULL,
    [SysDate]            DATETIME2 (7)  NOT NULL,
    [Email]              NVARCHAR (100) NULL,
    [isSent]             BIT            NULL,
    [BookingStatusId]    INT            NULL,
    [FirstReminderSent]  BIT            CONSTRAINT [DF_EventTransactionHeader_FirstReminderSent] DEFAULT ((0)) NOT NULL,
    [SecondReminderSent] BIT            CONSTRAINT [DF_EventTransactionHeader_SecondReminderSent] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EventTransactionHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

