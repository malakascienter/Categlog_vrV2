CREATE TABLE [dbo].[EventTransactionTicketDetail] (
    [ID]                       INT             IDENTITY (1, 1) NOT NULL,
    [EventTransactionDetailID] INT             NOT NULL,
    [TicketID]                 INT             NOT NULL,
    [BookQty]                  INT             NOT NULL,
    [Amount]                   DECIMAL (18, 2) NOT NULL,
    [TotalAmount]              DECIMAL (18, 2) NOT NULL,
    [OriginalTicketID]         INT             NULL,
    CONSTRAINT [PK_EventTicketDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

