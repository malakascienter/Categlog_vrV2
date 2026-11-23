CREATE TABLE [dbo].[DayEndDayEndStepCompletion] (
    [Id]             INT            IDENTITY (1, 1) NOT NULL,
    [HotelDate]      DATE           NOT NULL,
    [Step]           INT            NOT NULL,
    [IsCompleted]    BIT            DEFAULT ((0)) NOT NULL,
    [Narration]      NVARCHAR (250) DEFAULT (N'Not Executed') NOT NULL,
    [TxnDateTime]    DATETIME       DEFAULT (getdate()) NOT NULL,
    [UserId]         INT            NULL,
    [DayEndOutlet]   VARCHAR (5)    DEFAULT ('') NOT NULL,
    [PropertyId]     INT            DEFAULT ((0)) NOT NULL,
    [DayEndLocation] INT            DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_DayEndDayEndStepCompletion] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO

