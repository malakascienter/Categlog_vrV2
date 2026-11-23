CREATE TABLE [dbo].[PrinterSetup_History] (
    [Id]                 INT            NOT NULL,
    [Code]               VARCHAR (2)    NULL,
    [Name]               VARCHAR (50)   NULL,
    [Path]               NVARCHAR (MAX) NULL,
    [TicketNo]           INT            NULL,
    [PrintTicket]        BIT            NOT NULL,
    [AlternativePrinter] VARCHAR (50)   NULL,
    [Active]             BIT            NOT NULL,
    [SysDate]            DATETIME       CONSTRAINT [DF_PrinterSetup_History_SysDate] DEFAULT (getdate()) NOT NULL,
    [Printer]            VARCHAR (50)   NULL,
    [PropertyId]         INT            NULL,
    [IsUpload]           BIT            CONSTRAINT [DF_PrinterSetup_History_IsUpload] DEFAULT ((0)) NOT NULL,
    [CreatedUserId]      INT            NULL,
    [CreatedDateTime]    DATETIME       NULL,
    [UpdatedUserId]      INT            NULL,
    [UpdatedDateTime]    DATETIME       NULL
);


GO

