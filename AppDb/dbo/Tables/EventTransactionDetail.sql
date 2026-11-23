CREATE TABLE [dbo].[EventTransactionDetail] (
    [ID]                        INT           IDENTITY (1, 1) NOT NULL,
    [EventTransactionHeaderID]  INT           NOT NULL,
    [EventID]                   INT           NOT NULL,
    [EventDateDetailID]         INT           NOT NULL,
    [Date]                      DATETIME      NOT NULL,
    [IsComplete]                BIT           CONSTRAINT [DF_EventTransactionDetail_IsComplete] DEFAULT ((0)) NOT NULL,
    [CompleteDate]              DATETIME      NULL,
    [CompleteRemark]            VARCHAR (200) NULL,
    [OriginalEventDateDetailID] INT           NULL,
    [RetagCount]                INT           CONSTRAINT [DF_EventTransactionDetail_RetagCount] DEFAULT ((0)) NOT NULL,
    [LastRetagDate]             DATETIME      NULL,
    [LastRetagBy]               INT           NULL,
    [OriginalEventID]           INT           NULL,
    CONSTRAINT [PK_EventDetail] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

CREATE NONCLUSTERED INDEX [IX_EventTransactionDetail_DateDetail]
    ON [dbo].[EventTransactionDetail]([EventDateDetailID] ASC)
    INCLUDE([EventTransactionHeaderID], [EventID], [IsComplete]);


GO

