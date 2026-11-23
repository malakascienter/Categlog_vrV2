CREATE TABLE [dbo].[CommiTransferHeader] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [ProductionLocationID] INT           NULL,
    [RequestedLocationID]  INT           NULL,
    [TxnNo]                VARCHAR (50)  NULL,
    [TxnDate]              DATE          NULL,
    [UserID]               INT           NULL,
    [DeliveryScheduleID]   INT           NULL,
    [IsApproved]           BIT           CONSTRAINT [DF__CommiTran__IsApp__0FC7CD0C] DEFAULT ((0)) NOT NULL,
    [Status]               VARCHAR (5)   NULL,
    [LogDate]              DATETIME      CONSTRAINT [DF__CommiTran__LogDa__10BBF145] DEFAULT (getdate()) NOT NULL,
    [Remarks]              VARCHAR (MAX) NULL,
    [ReferenceID]          INT           NULL,
    [IsSPOBased]           BIT           CONSTRAINT [DF_CommiTransferHeader_IsSPOBased] DEFAULT ((0)) NULL,
    [SPOId]                INT           CONSTRAINT [DF_CommiTransferHeader_SPOId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CommiTransferHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

