CREATE TABLE [dbo].[CommiRequestDetails] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [HeaderID]           INT           NULL,
    [StockItemID]        INT           NULL,
    [UnitID]             INT           NULL,
    [Remarks]            VARCHAR (500) NULL,
    [RequestedQTY]       MONEY         CONSTRAINT [DF_CommiRequestDetails_RequestedQTY] DEFAULT ((0)) NOT NULL,
    [RequestedDate]      DATE          NULL,
    [DeliveryScheduleID] INT           NULL,
    [AdjustedQty]        MONEY         CONSTRAINT [DF_CommiRequestDetails_AdjustedQty] DEFAULT ((0)) NOT NULL,
    [ApprovedQTY]        MONEY         CONSTRAINT [DF_CommiRequestDetails_ApprovedQTY] DEFAULT ((0)) NOT NULL,
    [Status]             VARCHAR (5)   NULL,
    [LogDate]            DATETIME      CONSTRAINT [DF__CommiRequ__LogDa__054A3E99] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_CommiRequestDetails] PRIMARY KEY CLUSTERED ([ID] ASC)
);


GO

