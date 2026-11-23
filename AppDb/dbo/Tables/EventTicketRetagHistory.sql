CREATE TABLE [dbo].[EventTicketRetagHistory] (
    [Id]                       BIGINT          IDENTITY (1, 1) NOT NULL,
    [PropertyId]               INT             NOT NULL,
    [OutletCode]               VARCHAR (5)     NULL,
    [EventReservationID]       INT             NOT NULL,
    [EventTransactionHeaderID] INT             NOT NULL,
    [MobileNo]                 VARCHAR (20)    NULL,
    [CustomerName]             NVARCHAR (500)  NULL,
    [EventID]                  INT             NOT NULL,
    [EventNo]                  VARCHAR (50)    NULL,
    [EventName]                NVARCHAR (400)  NULL,
    [FromEventDateDetailID]    INT             NOT NULL,
    [FromEventDate]            DATE            NULL,
    [FromFromTime]             TIME (7)        NULL,
    [FromToTime]               TIME (7)        NULL,
    [ToEventDateDetailID]      INT             NOT NULL,
    [ToEventDate]              DATE            NULL,
    [ToFromTime]               TIME (7)        NULL,
    [ToToTime]                 TIME (7)        NULL,
    [PreviousBookingStatusId]  INT             NULL,
    [PreviousBookingStatus]    VARCHAR (50)    NULL,
    [PreviousIsComplete]       BIT             NULL,
    [NewBookingStatusId]       INT             NULL,
    [NewBookingStatus]         VARCHAR (50)    NULL,
    [NewIsComplete]            BIT             NULL,
    [TotalTickets]             INT             NULL,
    [TotalAmount]              DECIMAL (18, 2) NULL,
    [TargetTotalAmount]        DECIMAL (18, 2) NULL,
    [TicketMappingJson]        NVARCHAR (MAX)  NULL,
    [RetagSeqNo]               INT             NOT NULL,
    [RetaggedDate]             DATETIME        CONSTRAINT [DF_EventTicketRetagHistory_RetaggedDate] DEFAULT (getdate()) NOT NULL,
    [RetaggedBy]               INT             NOT NULL,
    [RetaggedByName]           NVARCHAR (100)  NULL,
    [Reason]                   NVARCHAR (500)  NULL,
    [SourceScreen]             VARCHAR (100)   NULL,
    [ToEventID]                INT             NULL,
    [ToEventNo]                VARCHAR (50)    NULL,
    [ToEventName]              NVARCHAR (400)  NULL,
    [IsCrossEvent]             BIT             CONSTRAINT [DF_EventTicketRetagHistory_IsCrossEvent] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_EventTicketRetagHistory] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_EventTicketRetagHistory_Property_Date]
    ON [dbo].[EventTicketRetagHistory]([PropertyId] ASC, [RetaggedDate] DESC);


GO

CREATE NONCLUSTERED INDEX [IX_EventTicketRetagHistory_Reservation]
    ON [dbo].[EventTicketRetagHistory]([EventReservationID] ASC, [Id] DESC);


GO

CREATE NONCLUSTERED INDEX [IX_EventTicketRetagHistory_Target]
    ON [dbo].[EventTicketRetagHistory]([ToEventDateDetailID] ASC);


GO

