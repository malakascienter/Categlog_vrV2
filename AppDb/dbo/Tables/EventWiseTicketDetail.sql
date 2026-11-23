CREATE TABLE [dbo].[EventWiseTicketDetail] (
    [TicketID]           INT             IDENTITY (1, 1) NOT NULL,
    [EventDateDetailsID] INT             CONSTRAINT [DF_EventWiseTicketDetail_EventDateDetailsId] DEFAULT ((0)) NOT NULL,
    [EventID]            INT             NOT NULL,
    [TicketName]         NVARCHAR (100)  NOT NULL,
    [Amount]             DECIMAL (18, 2) NOT NULL,
    [Qty]                INT             NOT NULL,
    CONSTRAINT [PK_EventWiseTicketDetail] PRIMARY KEY CLUSTERED ([TicketID] ASC)
);


GO

