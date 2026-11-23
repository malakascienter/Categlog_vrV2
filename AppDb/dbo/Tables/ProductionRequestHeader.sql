CREATE TABLE [dbo].[ProductionRequestHeader] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [ProductionLocationID] INT           NULL,
    [ProductionDate]       DATE          NULL,
    [TxnNo]                VARCHAR (500) NULL,
    [TxnDate]              DATE          NULL,
    [UserID]               INT           NULL,
    [DeliveryScheduleID]   INT           NULL,
    [Remarks]              NCHAR (500)   NULL,
    [IsApproved]           BIT           CONSTRAINT [DF__Productio__IsApp__0B0317EF] DEFAULT ((0)) NOT NULL,
    [Status]               VARCHAR (5)   NULL,
    [LogDate]              DATETIME      CONSTRAINT [DF__Productio__LogDa__0BF73C28] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ProductionRequestHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

