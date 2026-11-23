CREATE TABLE [dbo].[ProductionConsolidateHeader] (
    [ID]                 INT           IDENTITY (1, 1) NOT NULL,
    [PropertyID]         INT           NULL,
    [LocationID]         INT           NULL,
    [DocumentNo]         VARCHAR (MAX) NULL,
    [TxnDate]            DATE          NULL,
    [RequestedDate]      DATE          NULL,
    [Status]             CHAR (2)      NULL,
    [SysDateTime]        DATETIME      NULL,
    [UserID]             INT           NULL,
    [IsTransferComplete] BIT           CONSTRAINT [DF_ProductionConsolidateHeader_IsTransferComplete] DEFAULT ((0)) NULL,
    [Remarks]            VARCHAR (255) NULL
);


GO

