CREATE TABLE [dbo].[CommiRequestHeader] (
    [ID]                   INT           IDENTITY (1, 1) NOT NULL,
    [PropertyID]           INT           NULL,
    [RequestedLocationID]  INT           NULL,
    [ProductionLocationID] INT           NULL,
    [TxnNo]                VARCHAR (50)  NULL,
    [TaxnDate]             DATE          NULL,
    [RequestedDate]        DATE          NULL,
    [UserID]               INT           NULL,
    [Remarks]              VARCHAR (500) NULL,
    [IsApproved]           BIT           CONSTRAINT [DF__CommiRequ__IsApp__026DD1EE] DEFAULT ((0)) NOT NULL,
    [Status]               VARCHAR (50)  NULL,
    [LogDate]              DATETIME      CONSTRAINT [DF__CommiRequ__LogDa__0361F627] DEFAULT (getdate()) NOT NULL,
    [SendMail]             BIT           NULL,
    [IsSPOBased]           BIT           CONSTRAINT [DF_CommiRequestHeader_IsSPOBased] DEFAULT ((0)) NULL,
    [SPOId]                INT           CONSTRAINT [DF_CommiRequestHeader_SPOId] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_CommiRequestHeader] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

